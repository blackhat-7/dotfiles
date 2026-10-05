{ pkgs, ... }:

# Network monitoring on the Pi (system-manager on Raspberry Pi OS).
#   AdGuard Home  DNS for both routers; per-device query log   :53, UI :3001
#   Grafana       per-device traffic on Sedder (TP-Link C80)    :3000
# Web UIs are reachable only over Tailscale (see rpi-firewall).
# Router password lives outside nix in /etc/rpi-netmon.env (TPLINK_PASSWORD=...).
let
  scrapeInterval = "15s"; # traffic-dashboard.json multiplies by 15
  exporterPort = "9101";

  tplinkrouterc6u = pkgs.python3Packages.buildPythonPackage rec {
    pname = "tplinkrouterc6u";
    version = "5.36.0";
    pyproject = true;
    src = pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-+gf6FCXnovvyP5a07L8+MyIiZXkIG/bc4oOfPCVvxEQ=";
    };
    build-system = [ pkgs.python3Packages.setuptools ];
    dependencies = with pkgs.python3Packages; [
      requests
      pycryptodome
      macaddress
    ];
  };

  exporter = pkgs.writers.writePython3 "tplink-exporter" {
    libraries = [
      tplinkrouterc6u
      pkgs.python3Packages.prometheus-client
    ];
    flakeIgnore = [ "E501" ];
  } (builtins.readFile ./tplink-exporter.py);

  adguardConfig = (pkgs.formats.yaml { }).generate "AdGuardHome.yaml" {
    schema_version = pkgs.adguardhome.schema_version;
    http.address = "0.0.0.0:3001";
    users = [ ];
    dns = {
      bind_hosts = [ "0.0.0.0" ];
      port = 53;
      upstream_dns = [
        "https://dns.cloudflare.com/dns-query"
        "https://dns.quad9.net/dns-query"
      ];
      bootstrap_dns = [
        "1.1.1.1"
        "9.9.9.9"
      ];
      # Neither router answers reverse lookups.
      use_private_ptr_resolvers = false;
    };
    filters = [ ];
    filtering = {
      protection_enabled = false;
      filtering_enabled = false;
    };
    querylog.interval = "2160h";
    statistics.interval = "2160h";
  };

  prometheusConfig = (pkgs.formats.yaml { }).generate "prometheus.yml" {
    global.scrape_interval = scrapeInterval;
    scrape_configs = [
      {
        job_name = "tplink";
        static_configs = [ { targets = [ "127.0.0.1:${exporterPort}" ]; } ];
      }
    ];
  };

  grafanaProvisioning = pkgs.linkFarm "grafana-provisioning" {
    "datasources/prometheus.yaml" = (pkgs.formats.yaml { }).generate "prometheus.yaml" {
      apiVersion = 1;
      datasources = [
        {
          name = "Prometheus";
          uid = "prometheus";
          type = "prometheus";
          url = "http://127.0.0.1:9090";
          isDefault = true;
        }
        {
          name = "AdGuard";
          uid = "adguard";
          type = "yesoreyeram-infinity-datasource";
          url = "http://127.0.0.1:3001";
          jsonData.allowedHosts = [ "http://127.0.0.1:3001" ];
        }
      ];
    };
    "dashboards/dashboards.yaml" = (pkgs.formats.yaml { }).generate "dashboards.yaml" {
      apiVersion = 1;
      providers = [
        {
          name = "rpi";
          options.path = pkgs.linkFarm "grafana-dashboards" {
            "traffic.json" = ./traffic-dashboard.json;
          };
        }
      ];
    };
  };

  firewallRules = pkgs.writeText "rpi-firewall.nft" ''
    table inet rpi-firewall
    delete table inet rpi-firewall
    table inet rpi-firewall {
      chain input {
        type filter hook input priority filter; policy accept;
        iifname { "lo", "tailscale0" } accept
        tcp dport { 3000, 3001 } drop
      }
    }
  '';

  common = {
    DynamicUser = true;
    Restart = "always";
    RestartSec = 5;
  };
in
{
  systemd.services = {
    rpi-firewall = {
      wantedBy = [ "system-manager.target" ];
      before = [
        "adguardhome.service"
        "grafana.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.nftables}/bin/nft -f ${firewallRules}";
        ExecStop = "${pkgs.nftables}/bin/nft delete table inet rpi-firewall";
      };
    };

    adguardhome = {
      wantedBy = [ "system-manager.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = common // {
        StateDirectory = "AdGuardHome";
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        # Settings live here; changes made in the web UI are reset on restart.
        ExecStartPre = "${pkgs.coreutils}/bin/install -m 600 ${adguardConfig} %S/AdGuardHome/AdGuardHome.yaml";
        ExecStart = "${pkgs.adguardhome}/bin/AdGuardHome --no-check-update --work-dir %S/AdGuardHome --config %S/AdGuardHome/AdGuardHome.yaml";
      };
    };

    tplink-exporter = {
      wantedBy = [ "system-manager.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      environment = {
        TPLINK_HOST = "http://192.168.0.1";
        EXPORTER_PORT = exporterPort;
      };
      serviceConfig = common // {
        EnvironmentFile = "/etc/rpi-netmon.env";
        # A bad password must not trip the router's login lockout.
        RestartSec = 300;
        ExecStart = exporter;
      };
    };

    prometheus = {
      wantedBy = [ "system-manager.target" ];
      serviceConfig = common // {
        StateDirectory = "prometheus";
        ExecStart = "${pkgs.prometheus}/bin/prometheus --config.file=${prometheusConfig} --storage.tsdb.path=%S/prometheus --storage.tsdb.retention.time=400d --web.listen-address=127.0.0.1:9090";
      };
    };

    grafana = {
      wantedBy = [ "system-manager.target" ];
      environment = {
        GF_PATHS_DATA = "/var/lib/grafana";
        GF_PATHS_LOGS = "/var/lib/grafana/log";
        GF_PATHS_PLUGINS = "${pkgs.linkFarm "grafana-plugins" {
          yesoreyeram-infinity-datasource = pkgs.grafanaPlugins.yesoreyeram-infinity-datasource;
        }}";
        GF_PATHS_PROVISIONING = "${grafanaProvisioning}";
        GF_SERVER_HTTP_PORT = "3000";
        # Only reachable over Tailscale, so skip logins.
        GF_AUTH_ANONYMOUS_ENABLED = "true";
        GF_AUTH_DISABLE_LOGIN_FORM = "true";
        GF_ANALYTICS_REPORTING_ENABLED = "false";
        GF_ANALYTICS_CHECK_FOR_UPDATES = "false";
        GF_PLUGINS_PREINSTALL_DISABLED = "true";
        GF_DASHBOARDS_DEFAULT_HOME_DASHBOARD_PATH = "${./traffic-dashboard.json}";
      };
      serviceConfig = common // {
        StateDirectory = "grafana";
        ExecStart = "${pkgs.grafana}/bin/grafana server --homepath ${pkgs.grafana}/share/grafana";
      };
    };
  };
}

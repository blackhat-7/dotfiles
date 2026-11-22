{ config, pkgs, lib, inputs, ... }:

let
  home = config.users.users."illusion".home;
  tsWorkStateDir = "${home}/.local/state/tailscale-work";
  tsWork = "${pkgs.tailscale}/bin/tailscale --socket=${tsWorkStateDir}/tailscaled.sock";
  # macOS has no pam_exec: this module runs /etc/sudo-approve from sudo's PAM stack. It only
  # needs OpenPAM's headers; it calls nothing in libpam.
  pamSudoApprove = pkgs.runCommandCC "pam-sudo-approve" { } ''
    mkdir -p $out/lib/pam
    $CC -shared -Wall -Werror -I${pkgs.openpam}/include -o $out/lib/pam/pam_sudo_approve.so \
      ${../../scripts/sudo-approve/pam_sudo_approve.c}
  '';
  # The Touch ID box of sudo-approve-mac. It is named sudo because the box names the program
  # asking: "sudo is trying to run ...".
  touchidBox = pkgs.runCommandCC "sudo-approve-touchid" { } ''
    mkdir -p $out/libexec
    $CC -fobjc-arc -Wall -Werror -framework Foundation -framework LocalAuthentication \
      -o $out/libexec/sudo ${../../scripts/sudo-approve/touchid-prompt.m}
  '';
in
{
  nix.enable = false;
  # nix-darwin a1fa429 still passes the removed --toc-depth flag to
  # nixos-render-docs from current nixpkgs. Skip local Darwin manual output.
  documentation.enable = false;
  system.tools.darwin-uninstaller.enable = false;
  system.stateVersion = 4;
  system.primaryUser = "illusion";
  system.defaults = {
    dock = {
      autohide = true;
      orientation = "left";
      mru-spaces = false;
    };
    NSGlobalDomain.InitialKeyRepeat = 35;
    NSGlobalDomain.KeyRepeat = 2;
  };
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  programs = {
    fish.enable = true;
    zsh.enable = true;
  };

  # Keep fish listed as an acceptable login shell via a stable nix-darwin path.
  environment.shells = [ pkgs.fish ];

  fonts.packages = [
    pkgs.nerd-fonts.fira-code
  ];

  # Global system packages
  environment.systemPackages = with pkgs; [
    vim
    htop
    git
    go
    inputs.nix-darwin
    comma
    tailscale
  ];

  # Two tailnets at once. Only one tailscaled can own macOS routes/DNS, so:
  # - Home (headscale): the Tailscale app, full system VPN + DNS.
  # - Work (official Tailscale): this userspace tailscaled. It never touches
  #   routes or DNS; work traffic opts in through its HTTP + SOCKS5 proxy on
  #   127.0.0.1:1055 (ssh block below, curl -x, Zen via work.pac, DataGrip
  #   via driver VM options -DsocksProxyHost=127.0.0.1 -DsocksProxyPort=1055).
  # Where Tailscale is blocked (Oman), set the app's exit node to hetzner: this
  # daemon's control, DERP and WireGuard traffic then leaves from there too.
  # Login once (browser): ts-work up
  launchd.user.agents.tailscale-work = {
    command = ''
      ${pkgs.tailscale}/bin/tailscaled --tun=userspace-networking --statedir=${tsWorkStateDir} --socket=${tsWorkStateDir}/tailscaled.sock --outbound-http-proxy-listen=127.0.0.1:1055 --socks5-server=127.0.0.1:1055 --port=0
    '';
    serviceConfig = {
      KeepAlive = true;
      StandardErrorPath = "${home}/Library/Logs/tailscale-work.log";
      # Packets must fit inside the home tunnel (1280 bytes) when the hetzner
      # exit node carries them: 1200 + up to 80 bytes of WireGuard/UDP/IP headers.
      EnvironmentVariables.TS_DEBUG_MTU = "1200";
    };
  };

  # Zen's Work profile loads this PAC (user.js below, read at Zen startup).
  # Work MagicDNS names and IPs go to the proxy, the rest direct. Work IPs are
  # 100.64.0.0/10 minus 100.64.0.x, which headscale hands to home hosts.
  home-manager.users."illusion".home.file.".config/tailscale/work.pac".text = ''
    function FindProxyForURL(url, host) {
      if (dnsDomainIs(host, ".komodo-ghost.ts.net") ||
          (/^100\.(6[4-9]|[7-9]\d|1[01]\d|12[0-7])\.\d+\.\d+$/.test(host) && !/^100\.64\.0\./.test(host)))
        return "PROXY 127.0.0.1:1055";
      return "DIRECT";
    }
  '';
  home-manager.users."illusion".home.file."Library/Application Support/zen/Profiles/74lt2431.Work/user.js".text = ''
    user_pref("network.proxy.type", 2);
    user_pref("network.proxy.autoconfig_url", "file://${home}/.config/tailscale/work.pac");
  '';

  # Plain `ssh <host>` reaches work hosts: any host the work tailscaled knows
  # is tunnelled through it; home and internet hosts don't match and go
  # direct (home via the app). `tailscale ip` takes a short name or IP as-is,
  # but a MagicDNS FQDN only with a trailing dot, hence the second lookup.
  programs.ssh.extraConfig = ''
    Match exec "${tsWork} ip -4 %h >/dev/null 2>&1 || ${tsWork} ip -4 %h. >/dev/null 2>&1"
      ProxyCommand ${tsWork} nc %h %p
  '';

  # sudo approval when an AI agent runs sudo (scripts/sudo-approve, same as Linux): a Touch ID box
  # on this Mac, else the phone. Root-owned and read-only, with a fixed PATH since it runs as
  # root; ps comes from /bin. The tokens go in /etc/sudo-approve.conf by hand (README.md).
  environment.etc."sudo-approve".source = pkgs.writeShellScript "sudo-approve" ''
    export PATH=${lib.makeBinPath (with pkgs; [ coreutils curl jq ])}:/bin
    ${builtins.readFile ../../scripts/sudo-approve/sudo-approve}
  '';
  security.pam.services.sudo_local.text = "auth sufficient ${pamSudoApprove}/lib/pam/pam_sudo_approve.so";
  # Otherwise one approved sudo lets the same shell run more sudo commands for 5 minutes unasked.
  security.sudo.extraConfig = "Defaults timestamp_timeout=0";
  # Shows every agent's sudo, on the PC or this Mac, as a Touch ID box with the command.
  launchd.daemons.sudo-approve-mac = {
    command = "${pkgs.writeShellScript "sudo-approve-mac" ''
      export PATH=${lib.makeBinPath (with pkgs; [ coreutils curl jq ])}:/usr/sbin:/usr/bin:/bin
      ${builtins.readFile ../../scripts/sudo-approve/sudo-approve-mac}
    ''} ${touchidBox}/libexec/sudo";
    serviceConfig = {
      KeepAlive = true;
      StandardErrorPath = "/var/log/sudo-approve-mac.log";
    };
  };

  users.users."illusion" = {
    home = "/Users/illusion";
  };

  nixpkgs.config.allowUnfree = true;
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "bak";
    users."illusion".imports = [
      ../home
    ];
  };
}

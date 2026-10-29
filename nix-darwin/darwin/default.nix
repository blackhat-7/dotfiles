{ config, pkgs, inputs, ... }:

let
  home = config.users.users."illusion".home;
  tsWorkStateDir = "${home}/.local/state/tailscale-work";
  tsWork = "${pkgs.tailscale}/bin/tailscale --socket=${tsWorkStateDir}/tailscaled.sock";
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
  #   routes or DNS; work traffic opts in through its HTTP proxy on
  #   127.0.0.1:1055 (ssh block below, curl -x, Zen via work.pac).
  # Where Tailscale is blocked (Oman), set the app's exit node to hetzner: this
  # daemon's control, DERP and WireGuard traffic then leaves from there too.
  # Login once (browser): ts-work up
  launchd.user.agents.tailscale-work = {
    command = ''
      ${pkgs.tailscale}/bin/tailscaled --tun=userspace-networking --statedir=${tsWorkStateDir} --socket=${tsWorkStateDir}/tailscaled.sock --outbound-http-proxy-listen=127.0.0.1:1055 --port=0
    '';
    serviceConfig = {
      KeepAlive = true;
      StandardErrorPath = "${home}/Library/Logs/tailscale-work.log";
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

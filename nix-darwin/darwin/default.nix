{ config, pkgs, inputs, ... }:

let
  home = config.users.users."illusion".home;
  tsWorkStateDir = "${home}/.local/state/tailscale-work";
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

  # Userspace-only tailscaled joined to the work tailnet (official Tailscale),
  # so the Tailscale app (home headscale: TUN, routes, DNS) stays untouched.
  # Own state dir, socket and random UDP port; starts with the login session
  # and rejoins automatically after the one-time browser login (persisted in
  # the state dir). Work-tailnet apps opt in through its HTTP proxy on
  # 127.0.0.1:1055. Login once (browser): ts-work up
  launchd.user.agents.tailscale-work = {
    command = ''
      ${pkgs.tailscale}/bin/tailscaled --tun=userspace-networking --statedir=${tsWorkStateDir} --socket=${tsWorkStateDir}/tailscaled.sock --outbound-http-proxy-listen=127.0.0.1:1055 --port=0
    '';
    serviceConfig = {
      KeepAlive = true;
      StandardErrorPath = "${home}/Library/Logs/tailscale-work.log";
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

# ~/.config/nix-darwin/darwin-configuration.nix
{
  config,
  pkgs,
  inputs,
  localOverlays,
  ...
}:

{
  # This is a mandatory setting. It saves the Nix-Darwin version you are
  # using, which helps avoid breaking changes when you upgrade.
  # For a new install, you can start with 4.
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

  fonts.packages = [
    pkgs.meslo-lgs-nf
    pkgs.nerd-fonts.fira-code
  ];

  services = {
    tailscale.enable = true;
    # skhd = {
    #   enable = true;
    #   skhdConfig = ''
    #     # Remap Option + H/J/K/L using AppleScript
    #     alt - h : osascript -e 'tell application "System Events" to key code 123'
    #     alt - j : osascript -e 'tell application "System Events" to key code 125'
    #     alt - k : osascript -e 'tell application "System Events" to key code 126'
    #     alt - l : osascript -e 'tell application "System Events" to key code 124'
    #   '';
    # };
  };

  nixpkgs.overlays = localOverlays ++ [
    inputs.neovim-nightly-overlay.overlays.default
  ];
  
  # caps lock to control

  nix.enable = false;
  # nix.package = pkgs.nix;
  # nix.gc = {
  #   automatic = true;
  #   options = "--delete-older-than 7d";
  # };
  # services.nix-daemon.enable = true;

  # Install some command-line packages globally for all users.
  environment.systemPackages = with pkgs; [
    vim
    htop
    git
    go
    inputs.nix-darwin
  ];

  users.users."illusion" = {
    home = "/Users/illusion";
  };

  # Basic user configuration for Home Manager
  # This is where you configure your own user environment.
  nixpkgs.config.allowUnfree = true;
  home-manager = {
    backupFileExtension = "bak";
    users."illusion".imports = [
      ../home
    ];
  };
}

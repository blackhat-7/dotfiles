{ config, pkgs, inputs, ... }:

{
  nix.enable = false;
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
  ];

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

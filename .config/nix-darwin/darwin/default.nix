# ~/.config/nix-darwin/darwin-configuration.nix
{
  config,
  pkgs,
  inputs,
  ...
}:

{
  # This is a mandatory setting. It saves the Nix-Darwin version you are
  # using, which helps avoid breaking changes when you upgrade.
  # For a new install, you can start with 4.
  system.stateVersion = 4;

  programs = {
    fish.enable = true;
    zsh.enable = true;
  };

  services = {
    tailscale.enable = true;
  };

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
    # On macOS, this is the most important setting.
    # It tells nix-darwin that this user exists and where their home is.
    home = "/Users/illusion";
  };

  # Basic user configuration for Home Manager
  # This is where you configure your own user environment.
  home-manager = {
    backupFileExtension = "bak";
    users."illusion".imports = [../home];
  };
}

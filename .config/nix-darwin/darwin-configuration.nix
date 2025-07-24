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
  home-manager.users."illusion" =
    { pkgs, ... }:
    {
      home.stateVersion = "23.11"; # Or your desired version
      # Packages you want for your user
      home.packages = [
        pkgs.neofetch
        pkgs.colima
        pkgs.docker
        pkgs.docker-compose
        pkgs.exiftool
        pkgs.tailscale
        pkgs.python311
      ];

      programs = {
        neovim.enable = true;
        aichat.enable = true;
        direnv.enable = true;
        direnv.nix-direnv.enable = true;
        btop.enable = true;
        zoxide.enable = true;
        tmux.enable = true;
        lsd.enable = true;
      };

      # Docker daemon
      launchd.agents.colima = {
        enable = true;
        config = {
          # A label for the service
          Label = "com.abiosoft.colima";
          # The command to run
          ProgramArguments = [
            "${pkgs.colima}/bin/colima"
            "start"
          ];
          # Run the service when you log in
          RunAtLoad = true;
          # Keep the process alive, or restart if it dies
          KeepAlive = false;
          # Log files
          StandardOutPath = "/Users/illusion/Library/Logs/colima.log";
          StandardErrorPath = "/Users/illusion/Library/Logs/colima.error.log";
        };
      };
    };
}

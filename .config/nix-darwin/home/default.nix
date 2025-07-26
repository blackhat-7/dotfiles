{ pkgs, ... }:
{
  imports = [
    ./programs
  ];
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

  # services = {
  #   ollama.enable = true;
  # };

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
}

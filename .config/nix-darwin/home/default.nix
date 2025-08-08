{ pkgs, ... }:
{
  imports = [
    ./programs
  ];
  home.stateVersion = "23.11"; # Or your desired version
  # Packages you want for your user
  # nixpkgs.config.allowUnfree = true;
  home.packages = [
    pkgs.neofetch
    # pkgs.colima
    # pkgs.docker
    # pkgs.docker-compose
    pkgs.exiftool
    pkgs.tailscale
    pkgs.python311
    pkgs.opentofu
    pkgs.terragrunt
    (pkgs.google-cloud-sdk.withExtraComponents [pkgs.google-cloud-sdk.components.kubectl pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin])
    pkgs.golangci-lint
    pkgs.ollama
  ];


  # Launchd agent for Ollama service
  launchd.agents.ollama = {
    enable = true;
    config = {
      # Unique label for the Ollama service
      Label = "com.illusion.ollama";
      # Command to start the Ollama server
      ProgramArguments = [
        "${pkgs.ollama}/bin/ollama"
        "serve"
      ];
      # Start on load and keep alive
      RunAtLoad = true;
      KeepAlive = true;
      # Log standard output and errors
      StandardOutPath = "/Users/illusion/Library/Logs/ollama.log";
      StandardErrorPath = "/Users/illusion/Library/Logs/ollama.error.log";
    };
  };
}

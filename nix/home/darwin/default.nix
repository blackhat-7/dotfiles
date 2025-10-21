{ pkgs, lib, ... }:

{
  # Only enable these configurations on Darwin (macOS)
  config = lib.mkIf pkgs.stdenv.isDarwin {
    # Darwin-specific packages
    home.packages = with pkgs; [
      nightlight
      spotify
      slack
      discord
      raycast
      brave
      mongodb-compass
      (google-cloud-sdk.withExtraComponents [
        google-cloud-sdk.components.kubectl
        google-cloud-sdk.components.gke-gcloud-auth-plugin
      ])
      google-cloud-sql-proxy
      dbeaver-bin
      ollama
      exempi
    ];

    # Launchd agents (macOS services)
    targets.darwin.launchd.agents = {
      # Turn on night shift
      turn-on-night-shift = {
        enable = true;
        config = {
          ProgramArguments = [
            "${pkgs.nightlight}/bin/nightlight"
            "on"
          ];
          RunAtLoad = true;
        };
      };

      # Ollama service
      ollama = {
        enable = true;
        config = {
          Label = "com.illusion.ollama";
          ProgramArguments = [
            "${pkgs.ollama}/bin/ollama"
            "serve"
          ];
          RunAtLoad = true;
          KeepAlive = true;
          StandardOutPath = "/Users/illusion/Library/Logs/ollama.log";
          StandardErrorPath = "/Users/illusion/Library/Logs/ollama.error.log";
        };
      };
    };
  };
}

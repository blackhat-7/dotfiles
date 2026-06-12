{ pkgs, lib, config, inputs, ... }:
{
  imports = [
    ./programs
    inputs.ai-harnesses.homeManagerModules.default
  ];
  home.stateVersion = "23.11";
  home.packages = [
    pkgs.neovim
    pkgs.fastfetch
    pkgs.exiftool
    pkgs.python313
    pkgs.python313Packages.pip
    pkgs.opentofu
    (pkgs.google-cloud-sdk.withExtraComponents [pkgs.google-cloud-sdk.components.kubectl pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin])
    pkgs.golangci-lint
    pkgs.nightlight
    pkgs.nodejs_24
    pkgs.tree-sitter
    pkgs.spotify
    pkgs.slack
    pkgs.discord
    pkgs.raycast
    pkgs.google-cloud-sql-proxy
    pkgs.dbeaver-bin
    pkgs.jetbrains.datagrip
    pkgs.gopls
    pkgs.rustup
    pkgs.mongodb-compass
    pkgs.brave
    pkgs.ffmpeg_6-headless
    pkgs.exempi
    pkgs.sqlc
    pkgs.github-copilot-cli
    pkgs.p7zip
    pkgs.vi-mongo
    pkgs.tabiew
    pkgs.just
    pkgs.lazysql
    pkgs.packer
    pkgs.webtorrent_desktop
    pkgs.moonlight-qt
    pkgs.gitleaks
    pkgs.monitorcontrol
    pkgs.terminal-notifier
    pkgs.pandoc
  ];

  launchd.agents.turn-on-night-shift = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.nightlight}/bin/nightlight"
        "on"
      ];
      RunAtLoad = true;
    };
  };

  launchd.agents.pi-web = {
    enable = true;
    config = {
      # Replace pi-web's installer-generated LaunchAgent so the bind address is
      # declarative while keeping the token out of git.
      Label = "com.pi-web";
      ProgramArguments = [
        "${pkgs.bash}/bin/bash"
        "-lc"
        ''
          env_file="${config.home.homeDirectory}/.config/pi-web/env"
          /bin/mkdir -p "''${env_file%/*}"
          /usr/bin/grep -q '^PI_WEB_TOKEN=' "$env_file" 2>/dev/null ||
            printf 'PI_WEB_TOKEN=%s\n' "$(${pkgs.openssl}/bin/openssl rand -hex 16)" >> "$env_file"
          /bin/chmod 600 "$env_file"

          set -a
          . "$env_file"
          set +a

          exec "${config.home.homeDirectory}/.pi/agent/bin/pi-web" -p 31415 -host 0.0.0.0
        ''
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/tmp/pi-web.log";
      StandardErrorPath = "/tmp/pi-web.error.log";
      WorkingDirectory = "/tmp";
    };
  };
}

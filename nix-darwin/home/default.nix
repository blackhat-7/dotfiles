{ pkgs, ... }:
{
  imports = [
    ./programs
  ];
  home.stateVersion = "23.11";
  home.packages = [
    pkgs.fastfetch
    pkgs.exiftool
    pkgs.python313
    pkgs.python313Packages.pip
    pkgs.opentofu
    (pkgs.google-cloud-sdk.withExtraComponents [pkgs.google-cloud-sdk.components.kubectl pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin])
    pkgs.golangci-lint
    pkgs.nightlight
    pkgs.nodejs_24
    pkgs.spotify
    pkgs.slack
    pkgs.discord
    pkgs.raycast
    pkgs.google-cloud-sql-proxy
    pkgs.dbeaver-bin
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

  home.file.".claude.json" = {
    source = ../../claude/claude.json;
  };

  home.file.".config/opencode/package.json" = {
    source = ../../opencode/package.json;
  };

  home.file.".config/opencode/tools/reddit.ts" = {
    source = ../../opencode/tools/reddit.ts;
  };
}

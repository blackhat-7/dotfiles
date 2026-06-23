{ pkgs, inputs, ... }:

let
  genmedia =
    if pkgs ? genmedia then
      pkgs.genmedia
    else
      pkgs.callPackage ../../pkgs/genmedia.nix { };
in
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
    pkgs.opencode-desktop
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
    pkgs.jq
    pkgs.curl
    genmedia
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

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.file.".local/bin/img" = {
    source = ../../scripts/img;
    executable = true;
  };

  home.file.".local/bin/img-local-setup" = {
    source = ../../scripts/img-local-setup;
    executable = true;
  };

  home.file.".local/bin/img-local-server" = {
    source = ../../scripts/img-local-server;
    executable = true;
  };

  home.file.".local/bin/img-serve" = {
    source = ../../scripts/img-serve;
    executable = true;
  };

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

}

{ config, pkgs, inputs, ... }:

let
  genmedia =
    if pkgs ? genmedia then
      pkgs.genmedia
    else
      pkgs.callPackage ../../pkgs/genmedia.nix { };

  # Work around the current nixpkgs ld64 hardening crash on Darwin.
  moonlight = pkgs.moonlight-qt.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.llvmPackages.lld ];
    env = (old.env or { }) // {
      NIX_CFLAGS_LINK = "-fuse-ld=lld";
    };
  });

in
{
  imports = [
    ./programs
    ../../home-modules/paseo-plugins.nix
    inputs.ai-harnesses.homeManagerModules.default
  ];
  aiHarnesses.mode = "auto";
  aiHarnesses.pi.disabledPackages = [ "npm:pi-lean-ctx" ];
  home.stateVersion = "23.11";
  home.packages = [
    pkgs.neovim
    pkgs.fastfetch
    pkgs.exiftool
    (pkgs.lib.hiPrio pkgs.python313)
    (pkgs.lib.hiPrio pkgs.python313Packages.pip)
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
    pkgs.ffmpeg_6-headless
    pkgs.exempi
    pkgs.jq
    pkgs.curl
    pkgs.dtach
    genmedia
    pkgs.sqlc
    pkgs.github-copilot-cli
    pkgs.p7zip
    pkgs.vi-mongo
    # pkgs.tabiew
    pkgs.just
    pkgs.lazysql
    pkgs.packer
    pkgs.webtorrent_desktop
    moonlight
    pkgs.gitleaks
    pkgs.monitorcontrol
    pkgs.pandoc
  ];

  home.sessionPath = [
    "$HOME/.local/bin"
    # Paseo ships its own CLI; use it instead of a nix package so it can never
    # lag the desktop app.
    "/Applications/Paseo.app/Contents/Resources/bin"
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

  # The Paseo daemon runs at login without the app, from the app's own CLI so
  # the versions match. The app connects to a running daemon and stops only one
  # it started, so quitting it leaves this one up. After an app update, restart
  # it: launchctl kickstart -k gui/$(id -u)/org.nix-community.home.paseo
  launchd.agents.paseo = {
    enable = true;
    config = {
      ProgramArguments = [
        "/Applications/Paseo.app/Contents/Resources/bin/paseo"
        "daemon"
        "run"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      WorkingDirectory = config.home.homeDirectory;
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/paseo-daemon.log";
      # launchd ignores the shell's PATH; agents need claude, node, git and the like.
      EnvironmentVariables.PATH = builtins.concatStringsSep ":" [
        "${config.home.homeDirectory}/.npm-global/bin"
        "${config.home.homeDirectory}/.local/bin"
        "/etc/profiles/per-user/${config.home.username}/bin"
        "/run/current-system/sw/bin"
        "/nix/var/nix/profiles/default/bin"
        "/opt/homebrew/bin"
        "/usr/local/bin"
        "/usr/bin"
        "/bin"
        "/usr/sbin"
        "/sbin"
      ];
    };
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

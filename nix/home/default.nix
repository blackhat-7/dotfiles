{
  pkgs,
  config,
  lib,
  ...
}:

{
  imports = [ ./programs ];

  home.stateVersion = "23.11";

  # All packages consolidated
  home.packages = with pkgs; [
    # Common packages
    neofetch
    exiftool
    tailscale
    python313
    python313Packages.pip
    golangci-lint
    nodejs_24
    gopls
    tmux
    rustup
    git
    ffmpeg_6-headless
    exempi

    # Linux-specific packages
    firefox
    cowsay
    wine
    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.kubectl
      google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])
    docker
    just
    jdk21
    github-copilot-cli
    gemini-cli
    dbeaver-bin
    google-cloud-sql-proxy
    geeqie
    discord
    vi-mongo
    vicinae
    wl-clipboard
    mongodb-compass
    # element-desktop
  ];

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user.name = "blackhat-7";
      user.email = "palshaunak7@gmail.com";
    };
  };

  # Shell configuration
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ll = lib.mkForce "ls -la";
      ".." = "cd ..";
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
    shellAliases = {
      ll = lib.mkForce "ls -la";
      ".." = "cd ..";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Linux-specific activation
  home.activation.noisetorch-caps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    /usr/bin/sudo ${pkgs.libcap}/bin/setcap 'CAP_SYS_RESOURCE+ep' "${pkgs.noisetorch}/bin/noisetorch"
  '';

  # Enable generic Linux target
  targets.genericLinux.enable = true;

  # XDG configuration
  xdg.enable = true;

  # Systemd user services
  systemd.user.services.vicinae = {
    Unit = {
      Description = "Vicinae Launcher Server";
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.vicinae}/bin/vicinae server";
      Restart = "on-failure";
      RestartSec = "3s";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  wayland.windowManager.hyprland.systemd.enable = true;
}

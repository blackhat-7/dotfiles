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
    jq.enable = true;
    bat.enable = true;
    fzf.enable = true;
    kitty = {
      enable = true;
      extraConfig = ''
        hide_window_decorations      titlebar-only
        cursor_trail 3

        # background_opacity 0.8
        # background_blur -5

        font_size 14
        # font_family      MesloLGLDZ Nerd Font
        # bold_font        auto
        # italic_font      auto
        # bold_italic_font auto


        # BEGIN_KITTY_THEME
        # Catppuccin-Mocha
        include current-theme.conf
        # END_KITTY_THEME


        # BEGIN_KITTY_FONTS
        font_family      family="MesloLGLDZ Nerd Font"
        bold_font        auto
        italic_font      auto
        bold_italic_font auto
        # END_KITTY_FONTS
      '';
    };
  };

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

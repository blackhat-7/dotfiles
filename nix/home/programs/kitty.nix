{ pkgs, ...}: {
  programs.kitty = {
    enable = true;
    themeFile = "Catppuccin-Mocha";
    extraConfig = ''
      shell /home/illusion/.nix-profile/bin/fish
      hide_window_decorations      titlebar-only
      cursor_trail 3

      # background_opacity 0.8
      # background_blur -5


      # # BEGIN_KITTY_THEME
      # # Catppuccin-Mocha
      # include current-theme.conf
      # # END_KITTY_THEME


      # BEGIN_KITTY_FONTS
      font_size 14
      font_family      family="MesloLGLDZ Nerd Font"
      # font_family      family="FiraCode Nerd Font"
      bold_font        auto
      italic_font      auto
      bold_italic_font auto
      # END_KITTY_FONTS
    '';
  };
}

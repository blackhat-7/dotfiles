{ pkgs, ...}: {
  programs.kitty = {
    enable = true;
    themeFile = "Catppuccin-Mocha";
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


      # # BEGIN_KITTY_THEME
      # # Catppuccin-Mocha
      # include current-theme.conf
      # # END_KITTY_THEME


      # BEGIN_KITTY_FONTS
      font_family      family="MesloLGLDZ Nerd Font"
      bold_font        auto
      italic_font      auto
      bold_italic_font auto
      # END_KITTY_FONTS
    '';
  };
}

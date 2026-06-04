{ pkgs, ...}: {
  programs.kitty = {
    enable = true;
    package = null;
    extraConfig = ''
      # Oxocarbon is not in pkgs.kitty-themes, so keep it vendored.
      include ${../../../kitty/themes/oxocarbon-dark.conf}

      active_tab_font_style   bold
      inactive_tab_font_style normal
      tab_fade 0.1 0.2 0.8 1
      tab_bar_margin_width 1.0

      dim_opacity 0.3
      inactive_text_alpha 0.5
      draw_minimal_borders yes
      window_padding_width 10
      window_margin_width 0
      macos_option_as_alt yes

      hide_window_decorations      titlebar-only
      cursor_trail 3
      background_opacity 0.9

      font_size 14
      font_family      family="FiraCode Nerd Font"
      bold_font        auto
      italic_font      auto
      bold_italic_font auto
    '';
  };
}

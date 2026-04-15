{ pkgs, ...}: {
  programs.kitty = {
    enable = true;
    extraConfig = ''
# Monokai-pro for Kitty
# Based on https://www.monokai.pro/

foreground            #fcfcfa
background            #2d2a2e
selection_foreground  #19181a
selection_background  #ffd866
url_color             #78dce8
cursor                #fcfcfa
cursor_text_color     #2d2a2e

active_tab_background   #ffd866
active_tab_foreground   #19181a
active_tab_font_style   bold
inactive_tab_background #2d2a2e
inactive_tab_foreground #fcfcfa
inactive_tab_font_style normal
tab_fade 0.1 0.2 0.8 1
tab_bar_margin_width 1.0

dim_opacity 0.5
inactive_text_alpha 0.5
active_border_color #19181a
draw_minimal_borders yes
window_padding_width 10
window_margin_width 0
macos_titlebar_color background

# black
color0   #19181a
color8   #727072

# red
color1   #ff6188
color9   #ff6188

# green
color2   #a9dc76
color10  #a9dc76

# yellow
color3   #ffd866
color11  #ffd866

# blue
color4   #fc9867
color12  #fc9867

# magenta
color5   #ab9df2
color13  #ab9df2

# cyan
color6   #78dce8
color14  #78dce8

# white
color7   #fcfcfa
color15  #fcfcfa

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

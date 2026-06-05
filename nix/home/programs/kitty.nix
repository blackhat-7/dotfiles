{ pkgs, config, ... }: {
  programs.kitty = {
    enable = true;
    extraConfig = ''
      # Oxocarbon is not in pkgs.kitty-themes, so keep it vendored.
      include ${../../../kitty/themes/oxocarbon-dark.conf}

      shell /usr/bin/fish

      # Avoid Kitty 0.47.x recursively watching Nix/Home Manager symlink trees.
      auto_reload_config -1

      # Alt-click opens OSC-8 hyperlinks (file links from osc8wrap).
      mouse_map alt+left release grabbed,ungrabbed mouse_click_url
      mouse_map alt+left press grabbed mouse_discard_event

      hide_window_decorations      titlebar-only
      cursor_trail 3

      background_opacity 0.5
      background_blur 5


      # BEGIN_KITTY_FONTS
      font_size 12
      font_family      family="MesloLGLDZ Nerd Font"
      # font_family      family="FiraCode Nerd Font"
      bold_font        auto
      italic_font      auto
      bold_italic_font auto
      # END_KITTY_FONTS
    '';
  };

  xdg.configFile."kitty/open-actions.conf".text = ''
    protocol nvim,file
    action launch --type=background --cwd=current -- ${pkgs.python3}/bin/python3 ${config.home.homeDirectory}/dotfiles/scripts/open-editor-url ''${URL}
  '';
}

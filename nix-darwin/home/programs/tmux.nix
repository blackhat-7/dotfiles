{ pkgs, ... }: 
  let tmux-fzf-pane-switch = pkgs.tmuxPlugins.mkTmuxPlugin
    {
      name = "tmux-fzf-pane-switch";
      pluginName = "tmux-fzf-pane-switch";
      # version = "1.0";
      version = "unstable-2021-08-02";
      src = pkgs.fetchFromGitHub {
        owner = "Kristijan";
        repo = "tmux-fzf-pane-switch";
        rev = "0b8586ef41c45edfbd10bf2e5cefdda1b217f728";
        hash = "sha256-Kwvj92yUVRUbr0zHQQO5eoQwDtkqaLosWA4Q/nJ/+Mw=";
      };
      rtpFilePath = "select_pane.tmux";
    };
  in {
  programs.tmux = {
    enable = true;
    # shell = "${pkgs.fish}/bin/fish";
    # shell = "/run/current-system/sw/bin/fish";
    # prefix = "C-b";
    mouse = true;
    escapeTime = 0;
    plugins = with pkgs; [
        tmuxPlugins.sensible
        tmuxPlugins.yank
        tmuxPlugins.tmux-thumbs
        # tmuxPlugins.battery
        # tmuxPlugins.tmux-floax
        tmuxPlugins.vim-tmux-navigator
        # tmuxPlugins.tmux-fzf
        # tmuxPlugins.online-status
        {
            plugin = tmux-fzf-pane-switch;
            extraConfig = ''
                set -g @fzf_pane_switch_bind-key "M-f"
            '';
        }
    ];

    extraConfig = ''
      set-option -g default-shell "/run/current-system/sw/bin/fish"
      set -g default-command "/run/current-system/sw/bin/fish -l"

      set -g set-clipboard on

      # tmux scroll speed
      bind-key -T copy-mode-vi WheelUpPane send -N1 -X scroll-up
      bind-key -T copy-mode-vi WheelDownPane send -N1 -X scroll-down

      # Mouse scroll
      bind -Tcopy-mode WheelUpPane send -N1 -X scroll-up
      bind -Tcopy-mode WheelDownPane send -N1 -X scroll-down

      # New pane opens in cwd
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # Use vi keys
      set -gw mode-keys vi
      set -g status-keys vi

      # Styling
      # gruvbox material colorscheme
      RED="#ea6962"
      GREEN="#a9b665"
      YELLOW="#d8a657"
      BLUE="#7daea3"
      MAGENTA="#d3869b"
      CYAN="#89b482"
      BLACK="#1d2021"
      DARK_GRAY="#32302F"
      LIGHT_GRAY="#4F4946"
      BG="#32302F"
      FG="#d4be98"

      # Nerdfont characters
      HALF_ROUND_OPEN="#(printf '\uE0B6')"
      HALF_ROUND_CLOSE="#(printf '\uE0B4')"
      TRIANGLE_OPEN="#(printf '\uE0B2')"
      TRIANGLE_CLOSE="#(printf '\uE0B0')"

      # Status Bar
      set-option -g status-position bottom
      set-option -g status-style bg=$BG,fg=$FG
      set-option -g status-justify centre

      # Status left
      set-option -g status-left "\
#[fg=$LIGHT_GRAY,bg=default]$HALF_ROUND_OPEN\
#[bg=$LIGHT_GRAY,fg=$YELLOW]#S \
#[fg=$LIGHT_GRAY,bg=default]$TRIANGLE_CLOSE\
"

      # Status right
      set-option -g status-right "\
#[fg=$LIGHT_GRAY,bg=default]$TRIANGLE_OPEN\
#[bg=$LIGHT_GRAY,fg=$CYAN] #h\
#[fg=$LIGHT_GRAY,bg=default]$HALF_ROUND_CLOSE\
"

      set-option -g status-left-length 100
      set-option -g status-right-length 100

      # Window status - inactive
      set-option -g window-status-format "\
 \
#I\
#[fg=$MAGENTA]:\
#[fg=default]#W\
 \
"

      # Window status - active
      set-option -g window-status-current-format "\
#[fg=$LIGHT_GRAY,bg=default]$HALF_ROUND_OPEN\
#[bg=$LIGHT_GRAY,fg=default]#I\
#[fg=$RED]:\
#[fg=default]#W\
#[fg=$LIGHT_GRAY,bg=default]$HALF_ROUND_CLOSE\
"

      set-option -g window-status-separator ""

      # Pane and Window Automatic Rename
      set -wg automatic-rename on
      set -g automatic-rename-format "#{pane_current_command}"

      # Image preview
      set -g allow-passthrough on

      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM

      # Binds
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind C-e run-shell "$HOME/dotfiles/scripts/tmux-toggle-popup-terminal.sh '#{client_name}' '#{pane_current_path}' '#{session_name}' '#{window_id}'"

      bind C-f run-shell "$HOME/dotfiles/scripts/tmux-open-jump.sh '#{client_name}' '#{session_name}'"

      # Set status bar on/off
      bind C-s set-option -g status

      # Go to last window
      bind l last-window
    '';
  };
}

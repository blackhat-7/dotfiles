{ pkgs, inputs, ... }:
  let
    tmux-agent-radar = inputs.tmux-agent-radar.packages.${pkgs.stdenv.hostPlatform.system}.default;
    tmux-claude-usage = inputs.tmux-claude-usage.packages.${pkgs.stdenv.hostPlatform.system}.default;
    tmux-fzf-pane-switch = pkgs.tmuxPlugins.mkTmuxPlugin
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
    terminal = "tmux-256color";
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
            plugin = tmux-agent-radar;
            extraConfig = ''
                set -g @agent-radar-key "C-f"
                set -g @agent-radar-watch "on"
            '';
        }
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

      set -g extended-keys on
      set -g extended-keys-format csi-u
      set -g set-clipboard on

      # Tell tmux Kitty supports truecolor/RGB so colors match outside tmux.
      set -as terminal-features ",xterm-kitty:RGB"
      # Over ssh the client arrives as xterm-256color without COLORTERM, so
      # tmux would drop to 256 colors (and vellum.nvim images vanish).
      set -as terminal-features ",xterm-256color:RGB"
      # Preserve OSC-8 hyperlinks for Kitty Option-click.
      set -as terminal-features ",*:hyperlinks"

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

      # Styling: kanagawa dragon, transparent top bar
      %hidden TEXT="#c5c9c5"
      %hidden OLDWHITE="#c8c093"
      %hidden GRAY="#a6a69c"
      %hidden ASH="#737c73"
      %hidden DIM="#625e5a"
      %hidden BLACK5="#393836"
      %hidden BLACK4="#282727"
      %hidden BG="#181616"
      %hidden ORANGE="#b6927b"
      %hidden RED="#c4746e"
      %hidden YELLOW="#c4b28a"
      %hidden SELECTION="#2d4f67"

      # Status bar on top, with a blank second line as a spacer above panes
      set -g status 2
      set -g 'status-format[1]' ""
      set -g status-position top
      set -g status-justify left
      set -g status-style "bg=default,fg=$GRAY"
      set -g status-left-length 60
      set -g status-right-length 160

      # Session name turns red while prefix is held
      set -g status-left "#{?client_prefix,#[fg=$RED],#[fg=$ORANGE]}#[bold] #S  "
      set -g status-right "#(${tmux-claude-usage}/bin/tmux-claude-usage status)#[fg=$BLACK5]  ·  #[fg=$GRAY]#(${tmux-agent-radar}/bin/tmux-agent-radar status)#[fg=$BLACK5]  ·  #[fg=$GRAY]%H:%M "

      set -g window-status-separator ""
      set -g window-status-format "#[fg=$DIM]#I #[fg=$ASH]#W#{?window_zoomed_flag, 󰊓,}   "
      set -g window-status-current-format "#[fg=$ORANGE]#I #[fg=$TEXT,bold]#W#{?window_zoomed_flag,#[fg=$YELLOW] 󰊓,}   "
      set -g window-status-bell-style "fg=$RED,bold"

      # Panes, messages, copy mode, popups
      set -g pane-border-lines single
      set -g pane-border-style "fg=$BLACK4"
      set -g pane-active-border-style "fg=$DIM"
      # Title bar above each pane; agents (Claude, pi) set it to the session topic
      set -g pane-border-status top
      set -g pane-border-format " #{?pane_active,#[fg=$ORANGE bold],#[fg=$ASH]}#{pane_title} "
      set -g message-style "bg=default,fg=$OLDWHITE,bold"
      set -g message-command-style "bg=default,fg=$TEXT"
      set -g mode-style "bg=$SELECTION,fg=$OLDWHITE"
      set -g copy-mode-match-style "bg=$BLACK5,fg=$YELLOW"
      set -g copy-mode-current-match-style "bg=$ORANGE,fg=$BG"
      set -g popup-border-lines rounded
      set -g popup-border-style "fg=$DIM"
      set -g menu-border-lines rounded
      set -g menu-style "bg=default,fg=$TEXT"
      set -g menu-border-style "fg=$BLACK5"
      set -g menu-selected-style "bg=$BLACK4,fg=$ORANGE,bold"
      set -g display-panes-colour "$BLACK5"
      set -g display-panes-active-colour "$ORANGE"
      set -g clock-mode-colour "$ORANGE"

      # Pane and Window Automatic Rename
      set -wg automatic-rename on
      set -g automatic-rename-format "#{pane_current_command}"

      # Image preview
      set -g allow-passthrough on

      set -ga update-environment TERM_PROGRAM

      # Binds
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind C-e run-shell "$HOME/dotfiles/scripts/tmux-toggle-popup-terminal.sh '#{client_name}' '#{pane_current_path}' '#{session_name}' '#{window_id}'"

      # Set status bar on/off
      bind C-s set-option -g status

      # Go to last window
      bind l last-window
    '';
  };
}

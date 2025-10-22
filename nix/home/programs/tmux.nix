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
    prefix = "C-a";
    mouse = true;
    escapeTime = 0;
    plugins = with pkgs; [
        tmuxPlugins.sensible
        tmuxPlugins.yank
        tmuxPlugins.tmux-thumbs
        tmuxPlugins.battery
        # tmuxPlugins.tmux-floax
        tmuxPlugins.vim-tmux-navigator
        # tmuxPlugins.tmux-fzf
        {
            plugin = tmuxPlugins.catppuccin;
            extraConfig = ''
                set -g @catppuccin_flavor "mocha"
                set -g @catppuccin_status_background "none"
                set -g @catppuccin_window_status_style "none"
                set -g @catppuccin_pane_status_enabled "off"
                set -g @catppuccin_pane_border_status "off"
            '';
        }
        {
            plugin = tmuxPlugins.online-status;
            extraConfig = ''
                set -g @online_icon "ok"
                set -g @offline_icon "nok"
            '';
        }
        {
            plugin = tmux-fzf-pane-switch;
            extraConfig = ''
                set -g @fzf_pane_switch_bind-key "C-f"
            '';
        }
        # {
        #     plugin = tmuxPlugins.tmux-floax;
        #     extraConfig = ''
        #         set -g @floax-bind 'C-e'
        #     '';
        # }
    ];

    extraConfig = ''
      set-option -g default-shell "/usr/bin/fish"
      set -g default-command "/usr/bin/fish -l"

      # tmux scroll speed
      bind-key -T copy-mode-vi WheelUpPane send -N1 -X scroll-up
      bind-key -T copy-mode-vi WheelDownPane send -N1 -X scroll-down

      # Mouse scroll
      bind -Tcopy-mode WheelUpPane send -N1 -X scroll-up
      bind -Tcopy-mode WheelDownPane send -N1 -X scroll-down

      # New pane opens in cwd
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # set status-bg default
      # set -g status-position top
      # set -g pane-active-border-style 'fg=magenta,bg=default'
      # set -g pane-border-style 'fg=brightblack,bg=default'

      # Use vi keys
      set -gw mode-keys vi
      set -g status-keys vi

      # Status Bar

      ## status left look and feel
      set -g status-left-length 100
      set -g status-left ""
      set -ga status-left "#{?client_prefix,#{#[bg=#{@thm_red},fg=#{@thm_bg},bold]  #S },#{#[bg=#{@thm_bg},fg=#{@thm_green}]  #S }}"
      set -ga status-left "#[bg=#{@thm_bg},fg=#{@thm_overlay_0},none]│"
      set -ga status-left "#[bg=#{@thm_bg},fg=#{@thm_blue}]  #{=/-32/...:#{s|$USER|~|:#{b:pane_current_path}}} "
      set -ga status-left "#[bg=#{@thm_bg},fg=#{@thm_overlay_0},none]#{?window_zoomed_flag,│,}"
      set -ga status-left "#[bg=#{@thm_bg},fg=#{@thm_yellow}]#{?window_zoomed_flag,  zoom ,}"

      ## Status Bar - Right Look and Feel
      set -g status-right-length 100
      set -g status-right ""
      set -ga status-right "#{?#{e|>=:10,#{battery_percentage}},#{#[bg=#{@thm_red},fg=#{@thm_bg}]},#{#[bg=#{@thm_bg},fg=#{@thm_pink}]}} #{battery_icon} #{battery_percentage} "
      set -ga status-right "#[bg=#{@thm_bg},fg=#{@thm_overlay_0}, none]│"
      set -ga status-right "#[bg=#{@thm_bg}]#{?#{==:#{online_status},ok},#[fg=#{@thm_mauve}] 󰖩 on ,#[fg=#{@thm_red},bold]#[reverse] 󰖪 off }"

      ## General Status Bar Appearance
      set -g status-position bottom
      set -g status-style "bg=#{@thm_bg}"
      set -g status-justify "absolute-centre"

      # Window and Pane Styles
      set -wg automatic-rename on
      set -g automatic-rename-format "#{pane_current_command}"
      set -g window-status-format " #I#{?#{!=:#{window_name},Window},: #W,} "
      set -g window-status-style "bg=#{@thm_bg},fg=#{@thm_rosewater}"
      set -g window-status-last-style "bg=#{@thm_bg},fg=#{@thm_peach}"
      set -g window-status-activity-style "bg=#{@thm_red},fg=#{@thm_bg}"
      set -g window-status-bell-style "bg=#{@thm_red},fg=#{@thm_bg},bold"
      set -gF window-status-separator "#[bg=#{@thm_bg},fg=#{@thm_overlay_0}]│"
      set -g window-status-current-format " #I#{?#{!=:#{window_name},Window},: #W,} "
      set -g window-status-current-style "bg=#{@thm_peach},fg=#{@thm_bg},bold"


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

      # Set status bar on/off
      bind C-s set-option -g status

      # Go to last window
      bind l last-window
    '';
  };
}

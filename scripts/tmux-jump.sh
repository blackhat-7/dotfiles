#!/bin/sh
#
# tmux-jump.sh - fzf-based session/window switcher
#
# Called inside a display-popup -E:
#   tmux-jump.sh <target_client>
#
# Lists all windows across all sessions, lets user pick one via fzf,
# then switches the target client to that window.
#

target_client="$1"

# If no client was passed, try to determine it (fallback)
if [ -z "$target_client" ]; then
    target_client=$(tmux display-message -p '#{client_name}')
fi

# Run fzf to pick a target window
choice=$(
    tmux list-windows -a -F '#{session_name}:#{window_index}	#{session_name}: #{window_name}' |
        fzf --prompt='jump> ' --reverse --height=100% --with-nth=2.. --delimiter='	'
)

[ -n "$choice" ] || exit 0

target=$(printf '%s' "$choice" | cut -f1)

# Switch the target client to the selected session:window
tmux switch-client -c "$target_client" -t "$target"

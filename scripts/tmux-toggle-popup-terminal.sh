#!/bin/sh
#
# tmux-toggle-popup-terminal.sh - Toggle a persistent popup terminal
#
# Called from tmux binding:
#   run-shell "tmux-toggle-popup-terminal.sh '#{client_name}' '#{session_name}' '#{pane_current_path}'"
#
# When called from normal session: opens the popup terminal on this client.
# When called from inside popup-terminal: closes the popup by detaching the
# nested client. The popup shell exits and tmux closes it because it was opened
# with -E.
#

caller_client="$1"
current_session="$2"
start_dir="$3"

if [ "$current_session" = "popup-terminal" ]; then
    tmux detach-client 2>/dev/null
    exit 0
fi

tmux set-option -g @popup_terminal_parent_client "$caller_client"

if ! tmux has-session -t popup-terminal 2>/dev/null; then
    tmux new-session -d -s popup-terminal -n popup -c "$start_dir"
fi

tmux display-popup -c "$caller_client" -w 85% -h 85% -E \
    "tmux attach-session -t popup-terminal"

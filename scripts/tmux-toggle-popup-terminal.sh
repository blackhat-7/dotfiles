#!/bin/sh
#
# tmux-toggle-popup-terminal.sh - Toggle a per-window persistent popup terminal
#
# Called from tmux binding:
#   run-shell "tmux-toggle-popup-terminal.sh '#{client_name}' '#{pane_current_path}' '#{session_name}' '#{window_id}'"
#
# Each outer window gets its own popup session (popup-w<N>).
# Inside a popup session, C-b-e detaches (closes popup) instead of nesting.
#

caller_client="$1"
current_dir="$2"
current_session="$3"
window_id="$4"  # e.g. @2

# Strip the @ prefix so the session name has no special tmux characters
popup_session="popup-w${window_id#@}"

# If we're inside any popup-terminal session, just detach to close the popup.
# We check the prefix rather than an exact match because the inner session's
# window_id differs from the outer window's id that named this session.
case "$current_session" in
    popup-w*)
        tmux detach-client 2>/dev/null
        exit 0
        ;;
esac

# Create the session for this window if it doesn't exist yet
if ! tmux has-session -t "=$popup_session" 2>/dev/null; then
    tmux new-session -d -s "$popup_session" -c "$current_dir"
fi

# Open popup attached to this window's persistent session
tmux display-popup -c "$caller_client" -w 85% -h 85% -E \
    "tmux attach-session -t =$popup_session"

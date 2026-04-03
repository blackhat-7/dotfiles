#!/bin/sh
#
# tmux-open-jump.sh - Open the fzf session/window jumper
#
# Called via: run-shell "tmux-open-jump.sh '#{client_name}' '#{session_name}'"
#
# In normal context: opens a popup with fzf jump on the current client.
# In scratchpad context: closes the scratchpad popup first, then opens
# the fzf jump popup on the original parent client.
#

caller_client="$1"
current_session="$2"

case "$current_session" in
    scratchpad)
        parent_option='@scratchpad_parent_client'
        ;;
    popup-terminal)
        parent_option='@popup_terminal_parent_client'
        ;;
    *)
        parent_option=''
        ;;
esac

if [ -n "$parent_option" ]; then
    # We are inside a nested popup tmux session.
    # Read the saved parent client.
    parent_client=$(tmux show-options -gqv "$parent_option")
    if [ -z "$parent_client" ]; then
        parent_client="$caller_client"
    fi

    # Detach the inner popup client. This causes the popup's
    # shell command ("tmux attach-session -t scratchpad") to return,
    # and since the popup was opened with -E, it closes automatically.
    tmux detach-client -t "$caller_client" 2>/dev/null

    # Brief pause to let the popup fully close before opening a new one.
    sleep 0.15

    # Now open the jump popup on the parent (outer) client.
    tmux display-popup -c "$parent_client" -w 70% -h 60% -E \
        "$HOME/dotfiles/scripts/tmux-jump.sh '$parent_client'"
else
    # Normal case: just open the jump popup on the calling client.
    tmux display-popup -c "$caller_client" -w 70% -h 60% -E \
        "$HOME/dotfiles/scripts/tmux-jump.sh '$caller_client'"
fi

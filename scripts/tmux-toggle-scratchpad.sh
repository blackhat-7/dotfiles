#!/bin/sh
#
# tmux-toggle-scratchpad.sh - Toggle a scratchpad popup
#
# Called from tmux binding:
#   run-shell "tmux-toggle-scratchpad.sh '#{client_name}' '#{session_name}'"
#
# When called from normal session: opens scratchpad popup on this client.
# When called from inside scratchpad (nested tmux): closes the popup
# by detaching the inner client (the popup's -E flag auto-closes it).
#

caller_client="$1"
current_session="$2"

if [ "$current_session" = "scratchpad" ]; then
    # We are inside the scratchpad popup's nested tmux client.
    # Detaching this client causes "tmux attach-session -t scratchpad"
    # (the popup's shell command) to exit, and since the popup was
    # opened with -E, it closes automatically.
    tmux detach-client 2>/dev/null
    exit 0
fi

# Normal case: we are outside the scratchpad.
# Save our client name so scripts inside the scratchpad can find us.
tmux set-option -g @scratchpad_parent_client "$caller_client"

# Open the scratchpad popup on this client.
tmux display-popup -c "$caller_client" -w 85% -h 85% -E \
    "tmux attach-session -t scratchpad"

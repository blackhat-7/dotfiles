#!/bin/sh
# Toggle a per-tmux-window persistent popup shell.
#
# The popup itself is just a shell attached with dtach (not a nested tmux
# session). Each tmux window gets its own dtach socket, created in that
# window's current directory the first time it is opened.

caller_client="$1"
current_dir="${2:-$HOME}"
window_id="$4" # e.g. @2

uid=$(id -u 2>/dev/null || printf unknown)
runtime_dir="/tmp/tmux-popup-$uid"
mkdir -p "$runtime_dir" || exit 1
chmod 700 "$runtime_dir" 2>/dev/null || true

server_socket=$(tmux display-message -p '#{socket_path}' 2>/dev/null || printf '%s' "${TMUX%%,*}")
server_id=$(printf '%s' "$server_socket" | cksum | awk '{print $1}')
window_key=${window_id#@}

socket="$runtime_dir/$server_id-$window_key.sock"
visible="$runtime_dir/$server_id-$window_key.visible"
shell=${SHELL:-/bin/sh}
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
client_script="$script_dir/tmux-popup-dtach-client.py"

# If this window's popup is already open, close the tmux popup only. The
# dtach shell keeps running and will be reattached next time.
if [ -e "$visible" ]; then
    rm -f "$visible"
    tmux display-popup -c "$caller_client" -C
    exit 0
fi

dtach=$(command -v dtach)
python=$(command -v python3)
if [ -z "$dtach" ] || [ -z "$python" ]; then
    tmux display-message 'dtach and python3 are required for persistent non-tmux popups'
    exit 1
fi

if [ -S "$socket" ] && ! "$dtach" -p "$socket" </dev/null 2>/dev/null; then
    rm -f "$socket"
fi
if [ ! -S "$socket" ]; then
    (cd "$current_dir" && "$dtach" -n "$socket" "$shell" -l) || exit 1
fi

touch "$visible" || exit 1
tmux display-popup \
    -c "$caller_client" \
    -w 85% \
    -h 85% \
    -e "POPUP_PYTHON=$python" \
    -e "POPUP_CLIENT=$client_script" \
    -e "POPUP_DTACH=$dtach" \
    -e "POPUP_SOCKET=$socket" \
    -E sh -c 'exec "$POPUP_PYTHON" "$POPUP_CLIENT" "$POPUP_DTACH" "$POPUP_SOCKET"'
rm -f "$visible"

#!/bin/sh

create_session() {
    session_name=$1
    start_dir=$2
    window_name=$3

    tmux new-session -d -s "$session_name" -n "$window_name" "cd $start_dir && exec \$SHELL -l"
}

ensure_session() {
    session_name=$1
    start_dir=$2
    window_name=$3

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        create_session "$session_name" "$start_dir" "$window_name"
    fi
}

attach_session() {
    if [ -n "$TMUX" ]; then
        tmux switch-client -t "$1"
    else
        tmux attach-session -t "$1"
    fi
}

ensure_session "dotfiles" "$HOME/dotfiles" "code"
ensure_session "notes" "$HOME/dotfiles/Notes" "code"
ensure_session "Downloads" "$HOME/Downloads" "code"
ensure_session "projects" "$HOME/Documents/projects" "code"
ensure_session "editing-trainer" "$HOME/Documents/Work/Editing/editing-trainer" "code"
ensure_session "editing-preprocesser" "$HOME/Documents/Work/Editing/Editing-Preprocesser" "code"
ensure_session "editing-ml" "$HOME/Documents/Work/Editing/editing-ml" "code"
ensure_session "editingdebughelper" "$HOME/Documents/Work/Editing/EditingDebugHelper" "code"
ensure_session "aftershoot-cloud" "$HOME/Documents/Work/Editing/aftershoot-cloud" "code"
ensure_session "scratchpad" "$HOME/Downloads" "scratchpad"

if ! tmux has-session -t "services" 2>/dev/null; then
    tmux new-session -d -s "services" -n servers "cd $HOME && pdb"
    tmux split-window -h -t "services":servers "cd $HOME && sdb"
    tmux select-layout -t "services":servers even-horizontal
fi

attach_session "dotfiles"

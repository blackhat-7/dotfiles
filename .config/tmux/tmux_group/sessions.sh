#!/bin/sh

# Function to create a new session with a given name and first window name
create_session() {
    session_name=$1
    first_window_name=$2
    first_window_command=$3

    tmux new-session -d -s "$session_name" -n "$first_window_name"
    tmux send-keys "$first_window_command" C-m
}

# Function to add a new window to a session
add_window() {
    session_name=$1
    window_name=$2
    window_command=$3

    tmux new-window -t "$session_name" -n "$window_name"
    tmux send-keys "$window_command" C-m
}

new_window_in_session_with_4_way_split() {
    session_name=$1
    window_name=$2
    split_command1=$3
    split_command2=$4
    split_command3=$5
    split_command4=$6

    tmux new-window -t "$session_name" -n "$window_name"
    tmux send-keys "$split_command1" C-m
    tmux split-pane -v
    tmux send-keys "$split_command2" C-m
    tmux select-pane -t 0
    tmux split-window -h
    tmux send-keys "$split_command3" C-m
    tmux select-pane -t 2
    tmux split-window -h
    tmux send-keys "$split_command4" C-m
}

# Dotfiles
if ! tmux has-session -t Home 2>/dev/null; then
    create_session "Home" "Dotfiles" "cd ~/"
    add_window "Home" "Notes" "cd ~/Documents/Notes"
fi

# Main session with EP, ET, EA windows
if ! tmux has-session -t Main 2>/dev/null; then
    create_session "Main" "editing_preprocesser" "editing; cd Editing-Preprocesser/"
    add_window "Main" "editing_trainer" "editing; cd Editing-Trainer"
    add_window "Main" "aftershoot-cloud" "editing; cd aftershoot-cloud"
    add_window "Main" "infra" "editing; cd infra"
    add_window "Main" "editing-ml" "editing; cd editing-ml"
fi

# DebugHelper session with TT, PF windows
if ! tmux has-session -t DebugHelper 2>/dev/null; then
    create_session "DebugHelper" "model_sharing" "dh; cd model_sharing"
    add_window "DebugHelper" "train_trigger" "dh; cd train_trigger"
fi

# Scripts session with PT window
if ! tmux has-session -t Scripts 2>/dev/null; then
    create_session "Scripts" "Scripts" "sc"
fi

# Downloads
if ! tmux has-session -t Downloads 2>/dev/null; then
    create_session "Downloads" "Downloads" "cd ~/Downloads"
    add_window "Downloads" "Downloads" "cd ~/Downloads"
fi

# Hobby session with rc window
if ! tmux has-session -t Hobby 2>/dev/null; then
    create_session "Hobby" "RandomCodes" "rc"
fi

# Sessions and daemons
if ! tmux has-session -t Remote 2>/dev/null; then
    create_session "Services" "Services" "cd ~/"
    new_window_in_session_with_4_way_split "Serivces" "servers" "cd ~/ && pdb" "cd ~/ && sdb" "cd ~/" "cd ~/"
fi

# Attach to the main session or to the session that was just created
tmux attach-session -t Main

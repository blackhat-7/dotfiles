#!/bin/sh

# check if a tmux session with code is already running
if tmux has-session -t code 2>/dev/null; then
    # if so, attach to it
    tmux attach -t code
else
    tmux new-session -d -s 'code'
    tmux rename-window "nvim"
    tmux send-keys "cd ~/.config/nvim" C-m
    tmux new-window -n "EP"
    tmux send-keys "editing; cd Editing-Preprocesser" C-m
    tmux new-window -n "ET"
    tmux send-keys "editing; cd Editing-Trainer" C-m
    tmux new-window -n "EA"
    tmux send-keys "editing; cd Aftershoot-Editing-App" C-m
    tmux new-window -n "DH"
    tmux send-keys "editing; cd DebugHelpers" C-m
    tmux new-window -n "Scripts"
    tmux send-keys "editing; cd Scripts" C-m
    tmux new-window -n "Dwnlds"
    tmux send-keys "cd ~/Downloads" C-m
    tmux new-window -n "rc"
    tmux send-keys "rc" C-m
    tmux new-window
    tmux new-window

    tmux -2 attach-session -d
fi


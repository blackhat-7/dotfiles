#!/bin/sh
# check if a tmux session with code is already running
if tmux has-session -t server 2>/dev/null; then
    # if so, attach to it
    tmux attach -t server
else
    tmux new-session -d -s 'server'
    tmux send-keys "editing; cd Aftershoot-Desktop-App" C-m
    tmux split-pane -v
    tmux send-keys "editing; cd Downloads" C-m
    tmux select-pane -t 0
    tmux split-window -h
    tmux send-keys "editing; cd Desktop-Rust-Backend" C-m
    tmux select-pane -t 2
    tmux split-window -h
    tmux send-keys "editing; cd Aftershoot-Editing-App" C-m

    tmux -2 attach-session -d
fi

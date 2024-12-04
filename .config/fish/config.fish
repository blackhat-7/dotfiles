if status is-interactive
    # Commands to run in interactive sessions can go here


end

# exports

export FZF_DEFAULT_OPS="--extended"
export FZF_DEFAULT_COMMAND="fd --type f"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export HOMEBREW_NO_AUTO_UPDATE=1
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# GCP
export PROD_GCP_KEY="/Users/illusion/Documents/Work/Creds/edits_service_account_creds.json"
export STAGE_GCP_KEY="/Users/illusion/Documents/Work/Creds/stage_gcp.json"
export CROSS_GCP_KEY="/Users/illusion/Documents/Work/Creds/cross-accounts-service-account.json"
export GOOGLE_APPLICATION_CREDENTIALS=$CROSS_GCP_KEY

export EDITOR='nvim'
export LD_LIBRARY_PATH="/usr/local/opt/gettext/lib:$LD_LIBRARY_PATH"


# Aliases

alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"
alias push="git add -A && git commit -m 'Update' && git push"
alias work="cd ~/Documents/Work/"
alias rc="cd ~/Documents/randomCodes/"
alias mis="cd ~/Documents/Work/MIS/"
alias todo="cd ~/Documents/Work/todos"
alias editing="cd ~/Documents/Work/Editing/"
alias ep="editing && cd Editing-Preprocesser"
alias et="editing && cd Editing-Trainer"
alias dh="editing && cd DebugHelpers"
alias sc="editing && cd Scripts"
alias ms="editing && cd DebugHelpers/model_sharing"
alias fishrc="nv ~/.config/fish/config.fish"
alias source_fishrc="source ~/.config/fish/config.fish"
alias ls="lsd"
alias l="ls"
alias snp="/Users/illusion/Documents/randomCodes/snippets/snippets.sh"
alias aseprite="/Users/illusion/Documents/Hobby/source/aseprite/build/bin/aseprite"
alias fe="/opt/homebrew/bin/yazi"
alias cat=bat

# Nvim configs
alias nvim="/Users/illusion/nvim/bin/nvim"
alias nv="nvim -u ~/.config/nvim/init.lua"
alias nvi="nvim -u ~/.config/nvim_dt/init.lua"
alias nvrc="cd ~/.config/nvim && nv"

# Game alias
alias minecraft="sudo java -jar ~/Documents/Games/minecraft/TLauncher-2.885.jar"

# Tmux envs
alias sessions="/Users/illusion/Documents/randomCodes/shortcuts/tmux_group/sessions.sh"
alias code-tmux="/Users/illusion/Documents/randomCodes/shortcuts/tmux_group/code.sh"
alias server-tmux="/Users/illusion/Documents/randomCodes/shortcuts/tmux_group/server.sh"
alias app-kill="/Users/illusion/Documents/randomCodes/shortcuts/spotify_kill/main.sh"
alias long_training_jobs="/Users/illusion/Documents/Work/Editing/DebugHelpers/long_training/long_training_jobs"
alias gcp_stage="source /Users/illusion/Documents/Work/Creds/gcp_stage.sh"
alias gcp_prod="source /Users/illusion/Documents/Work/Creds/gcp_prod.sh"

starship init fish | source

# Brew
eval "$(/opt/homebrew/bin/brew shellenv)"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /Users/illusion/miniconda3/bin/conda
    eval /Users/illusion/miniconda3/bin/conda "shell.fish" "hook" $argv | source
end
# <<< conda initialize <<<

conda deactivate
conda activate

# zoxide
zoxide init fish | source
alias cd="z"

# For vi key bindings in terminal
fish_vi_key_bindings

# atuin
atuin init fish | source

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

# Doom emacs
export PATH="$HOME/.config/emacs/bin:$PATH"

# opam configuration
source /Users/illusion/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true

# GOLANG
export GOPATH=$HOME/go
export PATH="$GOPATH/bin:$PATH"
# export GOTRACEBACK=all

# Zellij
export ZELLIJ_CONFIG_DIR=/Users/illusion/.config/zellij
export ZELLIJ_CONFIG_FILE=/Users/illusion/.config/zellij/config.kdl

# vcpkg
export VCPKG_ROOT="/Users/illusion/Documents/Work/Editing/vcpkg"
export PATH="$VCPKG_ROOT:$PATH"
export CMAKE_TOOLCHAIN_FILE="$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake"
export CMAKE_MAKE_PROGRAM=/usr/bin/make
# export HOME_MANAGER_CONFIG="~/.config/nixpkgs/"

# Aichat
function _aichat_fish
    set -l _old (commandline)
    if test -n $_old
        echo -n "⌛"
        commandline -f repaint
        commandline (aichat -e $_old)
    end
end
bind -M insert \cx _aichat_fish
# function _aichat_fish
#     # Save the current command line content to a variable
#     set _old (commandline)
#     
#     # If the current command line is not empty
#     if test -n "$_old"
#         # Print an indicator to show that processing is happening
#         echo -n "⌛"
#         
#         # Force a repaint of the command line interface to show the indicator
#         commandline -f repaint
#         
#         # Call `aichat` with the current command line content and replace the content with the result
#         set _new (aichat -e "$_old")
#         
#         # Replace the command line with the output of the `aichat` command
#         commandline -r "$_new"
#     end
# end

source /Users/illusion/.docker/init-fish.sh || true # Added by Docker Desktop


# export OPENAI_API_BASE="http://100.95.18.138:42069/v1"
export OPENAI_API_BASE="https://glhf.chat/api/openai/v1"
export AIDER_MODEL="hf:Qwen/Qwen2.5-Coder-32B-Instruct"
export OPENAI_API_KEY=$(cat $HOME/Documents/Creds/glhf.txt)

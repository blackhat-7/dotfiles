{ pkgs, ... }: {
  programs.fish = {
    enable = true;
    generateCompletions = true;
    functions = {
        gcm = ''
          # 1. Stage all changes
          echo "➕ Staging all changes..."
          git add -A

          # 2. Check for staged changes
          set -l diff_output (git diff --cached)

          if test -z "$diff_output"
              echo "🚫 No changes found to commit."
              return 1
          end

          # 3. Inform user
          echo "🤖 Generating commit message..."

          # 4. Construct the prompt
          set -l prompt "Your task is to generate a concise and informative commit message based on the provided diff. Use the conventional commit format (type: subject). The message should be in the imperative mood and under 200 chars. Don't include additional text. The diff is:
          $diff_output"

          # 5. Call aichat
          set -l ai_msg (echo "$prompt" | aichat)

          # 6. Process the output
          if test $status -eq 0 -a -n "$ai_msg"
              # Remove <think>...</think> blocks using regex
              # We use "" for the empty string replacement
              set ai_msg (string replace -r -a '(?s)<think>.*?</think>' "" "$ai_msg")
              
              # Trim surrounding whitespace
              set ai_msg (string trim "$ai_msg")
              
              # Escape double quotes to ensure the command is valid
              set -l escaped_msg (string replace -a '"' '\"' "$ai_msg")
              
              # Replace 'gcm' with the final git command
              commandline -r "git commit -m \"$escaped_msg\""
          else
              echo "❌ Failed to generate message."
              return 1
          end
        '';
        ocn = ''
          set -l cmd opencode

          if test (count $argv) -gt 0
              set cmd "$cmd "(string join ' ' (string escape -- $argv))
          end

          if set -q TMUX
              tmux new-window -n opencode -c "$PWD" "$cmd"
          else
              eval $cmd
          end
        '';
    };
    shellInit = ''
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
alias dh="editing && cd EditingDebugHelper"
alias sc="editing && cd Scripts"
alias ms="editing && cd DebugHelpers/model_sharing"
alias fishrc="nv ~/.config/fish/config.fish"
alias source_fishrc="source ~/.config/fish/config.fish"
alias ls="lsd"
alias l="ls"
alias snp="/Users/illusion/Documents/randomCodes/snippets/snippets.sh"
alias aseprite="/Users/illusion/Documents/Hobby/source/aseprite/build/bin/aseprite"
alias fe="/opt/homebrew/bin/yazi"
alias pdb="cloud-sql-proxy aftershoot-co:us-central1:editing-uploader -p 5434"
alias sdb="cloud-sql-proxy aftershoot-stage:us-central1:aftershoot-stage-db -p 5436"
alias jbuild="cd ./secret/jarvis && cargo build --release && cd - && mv ./secret/jarvis/target/release/jarvis ."
alias initflake="~/dotfiles/scripts/init-direnv-flake.sh"
alias ccr-local="ccr code --model local,Qwen3.5-9B-Q4_K_M.gguf"
alias chutes="uv run --project ~/Documents/projects/chutes-tui ~/Documents/projects/chutes-tui/main.py"
        alias ccr-glm="ccr code --model chutes,zai-org/GLM-5.1-TEE"
alias ccr-kimi="ccr code --model chutes,moonshotai/Kimi-K2.5-TEE"

# Nvim configs
alias nv="nvim -u ~/.config/nvim/init.lua"
alias nvi="nvim -u ~/.config/nvim_dt/init.lua"
alias nvrc="cd ~/.config/nvim && nv"

# Game alias
alias minecraft="sudo java -jar ~/Documents/Games/minecraft/TLauncher-2.885.jar"

# Tmux envs
alias sessions="~/dotfiles/scripts/sessions.sh"
alias long_training_jobs="/Users/illusion/Documents/Work/Editing/DebugHelpers/long_training/long_training_jobs"
alias gcp_stage="source /Users/illusion/Documents/Work/Creds/gcp_stage.sh"
alias gcp_prod="source /Users/illusion/Documents/Work/Creds/gcp_prod.sh"

starship init fish | source

# Brew
eval "$(/opt/homebrew/bin/brew shellenv)"


# zoxide
zoxide init fish | source
alias cd="z"

# For vi key bindings in terminal
fish_vi_key_bindings

# atuin
atuin init fish | source

# carapace
set -Ux CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense'
carapace _carapace | source

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

# npm
export PATH="$HOME/.npm-global/bin:$PATH"

# Doom emacs
export PATH="$HOME/.config/emacs/bin:$PATH"

# opam configuration
source /Users/illusion/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true

# GOLANG
export GOPATH=$HOME/go
export PATH="$GOPATH/bin:$PATH"

# Zellij
export ZELLIJ_CONFIG_DIR=/Users/illusion/.config/zellij
export ZELLIJ_CONFIG_FILE=/Users/illusion/.config/zellij/config.kdl

# vcpkg
export VCPKG_ROOT="/Users/illusion/Documents/Work/Editing/vcpkg"
export PATH="$VCPKG_ROOT:$PATH"
export CMAKE_TOOLCHAIN_FILE="$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake"
export CMAKE_MAKE_PROGRAM=/usr/bin/make

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

export OPENAI_API_BASE="http://100.85.231.84:8080/api"
export AIDER_MODEL="hf:Qwen/Qwen2.5-Coder-32B-Instruct"
export OPENAI_API_KEY=$(cat $HOME/Documents/Creds/owui.txt)
export GEMINI_API_KEY=$(cat $HOME/Documents/Creds/gemini.txt)
export OLLAMA_HOST="0.0.0.0"
export SEARXNG_API_URL="http://135.181.228.158:9000"
export OPENROUTER_API_KEY=$(cat $HOME/Documents/Creds/openrouter.txt)
if test -f $HOME/Documents/Creds/chutes.txt
    export CHUTES_API_KEY=$(cat $HOME/Documents/Creds/chutes.txt)
end
if test -f $HOME/Documents/Work/Creds/linear.txt
    export LINEAR_API_KEY=$(cat $HOME/Documents/Work/Creds/linear.txt)
end
if test -f $HOME/Documents/Creds/huggingface.txt
    export HF_TOKEN=$(cat $HOME/Documents/Creds/huggingface.txt)
end
if test -f $HOME/Documents/Work/Creds/github-mcp.txt
    export GITHUB_MCP_TOKEN=$(cat $HOME/Documents/Work/Creds/github-mcp.txt)
end

direnv hook fish | source
    '';
  };
}

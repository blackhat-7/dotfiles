{
  pkgs,
  config,
  lib,
  ...
}:

{
  imports = [ ./programs ];

  home.stateVersion = "23.11";

  # All packages consolidated
  home.packages = with pkgs; [
    # Common packages
    neovim
    fastfetch
    exiftool
    tailscale
    python313
    python313Packages.pip
    golangci-lint
    nodejs_24
    tree-sitter
    gopls
    tmux
    rustup
    git
    ffmpeg_6-headless
    exempi

    # Linux-specific packages
    firefox
    cowsay
    wine
    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.kubectl
      google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])
    docker
    just
    jdk21
    github-copilot-cli
    gemini-cli
    dbeaver-bin
    google-cloud-sql-proxy
    geeqie
    discord
    vi-mongo
    vicinae
    wl-clipboard
    mongodb-compass
    # element-desktop
    gitleaks
    claude-code-router
  ];

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user.name = "blackhat-7";
      user.email = "palshaunak7@gmail.com";
      core.hooksPath = "~/.githooks";
    };
    signing.format = null;
  };

  home.file.".githooks/pre-commit" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      exec gitleaks protect --staged --verbose --config "$HOME/.config/gitleaks/config.toml"
    '';
  };

  home.activation.writeCcrConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.claude-code-router"
    cat > "$HOME/.claude-code-router/config.json" <<'EOF'
{
  "Providers": [
    {
      "name": "local",
      "api_base_url": "http://100.64.0.1:6868/v1/messages",
      "api_key": "none",
      "models": [
        "Qwen3.5-9B-Q4_K_M.gguf"
      ],
      "transformer": {
        "use": [
          "Anthropic"
        ]
      }
    },
    {
      "name": "chutes",
      "api_base_url": "https://llm.chutes.ai/v1/chat/completions",
      "api_key": "$CHUTES_API_KEY",
      "models": [
        "zai-org/GLM-5-Turbo",
        "moonshotai/Kimi-K2.5-TEE"
      ],
      "transformer": {
        "use": [
          "deepseek"
        ]
      }
    }
  ],
  "Router": {
    "default": "chutes,zai-org/GLM-5-Turbo",
    "background": "local,Qwen3.5-9B-Q4_K_M.gguf"
  }
  }
EOF
  '';

  home.activation.writeMutableAiConfigs =
    let
      statuslineScript = ''
        #!/usr/bin/env bash
        # Claude Code status line - mirrors Starship config (nix/home/programs/starship.nix)

        input=$(cat)

        cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
        model=$(echo "$input" | jq -r '.model.display_name // ""')
        used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

        # Directory: truncation_length=3, truncation_symbol="…/"
        home="$HOME"
        dir="''${cwd/#$home/~}"
        IFS='/' read -ra parts <<< "$dir"
        count="''${#parts[@]}"
        if [ "$count" -gt 3 ]; then
          dir="…/''${parts[$((count-3))]}/''${parts[$((count-2))]}/''${parts[$((count-1))]}"
        fi

        # Git branch: symbol="" format="on [$symbol$branch]($style) "
        git_info=""
        if git_branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null); then
          git_status_flags=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
          git_status_str=""
          if [ -n "$git_status_flags" ]; then
            staged=$(echo "$git_status_flags" | grep -c '^[MADRC]' || true)
            modified=$(echo "$git_status_flags" | grep -c '^ M\| M' || true)
            untracked=$(echo "$git_status_flags" | grep -c '^??' || true)
            flags=""
            [ "$staged" -gt 0 ]    && flags="''${flags}+"
            [ "$modified" -gt 0 ]  && flags="''${flags}!"
            [ "$untracked" -gt 0 ] && flags="''${flags}?"
            [ -n "$flags" ] && git_status_str="[$flags]"
          fi
          git_info=" on  ''${git_branch}''${git_status_str:+ $git_status_str}"
        fi

        # Python: format="via [$symbol($virtualenv)]($style) "
        python_info=""
        if [ -n "$VIRTUAL_ENV" ]; then
          venv_name=$(basename "$VIRTUAL_ENV")
          python_info=" via 🐍(''${venv_name})"
        fi

        ctx_info=""
        if [ -n "$used_pct" ]; then
          printf -v ctx_rounded "%.0f" "$used_pct"
          ctx_info=" | ctx ''${ctx_rounded}%"
        fi

        model_info=""
        [ -n "$model" ] && model_info=" | ''${model}"

        printf "\033[1;36m%s\033[0m" "$dir"
        printf "\033[1;35m%s\033[0m" "$git_info"
        [ -n "$python_info" ] && printf "\033[1;33m%s\033[0m" "$python_info"
        printf "\033[0;37m%s%s\033[0m" "$ctx_info" "$model_info"
        printf "\n"
      '';

      notifyScript = ''
        #!/usr/bin/env bash
        input=$(cat)
        event=$(printf '%s' "$input" | jq -r '.hook_event_name // ""')
        case "$event" in
          Stop)
            title="Claude Code"
            message="Done"
            urgency="normal"
            ;;
          *)
            title=$(printf '%s' "$input" | jq -r '.title // "Claude Code"')
            message=$(printf '%s' "$input" | jq -r '.message // ""')
            urgency="critical"
            ;;
        esac
        notify-send -u "$urgency" -a "Claude Code" "$title" "$message"
      '';
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/.claude"

      rm -f "$HOME/.claude/statusline-command.sh"
      cat <<'EOF' > "$HOME/.claude/statusline-command.sh"
      ${statuslineScript}
      EOF
      chmod +x "$HOME/.claude/statusline-command.sh"

      rm -f "$HOME/.claude/notify.sh"
      cat <<'EOF' > "$HOME/.claude/notify.sh"
      ${notifyScript}
      EOF
      chmod +x "$HOME/.claude/notify.sh"

      rm -f "$HOME/.claude/settings.json"
      cat <<'EOF' > "$HOME/.claude/settings.json"
      {
        "$schema": "https://json.schemastore.org/claude-code-settings.json",
        "viewMode": "verbose",
        "statusLine": {
          "type": "command",
          "command": "bash ${config.home.homeDirectory}/.claude/statusline-command.sh"
        },
        "permissions": {
          "allow": [
            "Read",
            "Glob",
            "Grep",
            "LSP",
            "Task",
            "WebFetch",
            "WebSearch",
            "mcp__cloudsql-reader",
            "mcp__mongo-reader",
            "mcp__stage-mongo-reader",
            "mcp__grafana-loki-reader",
            "mcp__sentry-reader",
            "mcp__arxiv",
            "mcp__bestiary",
            "mcp__chrome-devtools",
            "mcp__github"
          ],
          "deny": [],
          "ask": [
            "Edit",
            "Write"
          ]
        },
        "enabledPlugins": {
          "pyright-lsp@claude-plugins-official": true,
          "gopls-lsp@claude-plugins-official": true
        },
        "hooks": {
          "Notification": [
            {
              "matcher": "",
              "hooks": [
                {
                  "type": "command",
                  "command": "bash ${config.home.homeDirectory}/.claude/notify.sh"
                }
              ]
            }
          ],
          "Stop": [
            {
              "matcher": "",
              "hooks": [
                {
                  "type": "command",
                  "command": "bash ${config.home.homeDirectory}/.claude/notify.sh"
                }
              ]
            }
          ]
        }
      }
      EOF

      rm -f "$HOME/.claude.json"
      cat <<'EOF' > "$HOME/.claude.json"
      {
        "mcpServers": {
          "bestiary": {
            "command": "uvx",
            "args": ["--from", "git+https://github.com/blackhat-7/bestiary.git@main", "bestiary", "serve"]
          },
          "github": {
            "type": "http",
            "url": "https://api.githubcopilot.com/mcp/",
            "headers": {
              "Authorization": "Bearer ''${GITHUB_MCP_TOKEN}"
            }
          },
          "chrome-devtools": {
            "command": "npx",
            "args": ["chrome-devtools-mcp@latest"]
          },
          "cloudsql-reader": {
            "command": "${config.home.homeDirectory}/.npm-global/bin/env-cmd",
            "args": ["-f", "${config.home.homeDirectory}/Documents/Work/Editing/aftershoot-cloud/env/dev/cloudsql-reader/app.env", "${config.home.homeDirectory}/Documents/Work/Editing/aftershoot-cloud/dist/mcp-servers/cloudsql-reader"]
          },
          "grafana-loki-reader": {
            "command": "${config.home.homeDirectory}/.npm-global/bin/env-cmd",
            "args": ["-f", "${config.home.homeDirectory}/Documents/Work/Editing/aftershoot-cloud/env/dev/grafana-loki-reader/app.env", "${config.home.homeDirectory}/Documents/Work/Editing/aftershoot-cloud/dist/mcp-servers/grafana-loki-reader"],
            "disabled": true
          },
          "mongo-reader": {
            "command": "${config.home.homeDirectory}/.npm-global/bin/env-cmd",
            "args": ["-f", "${config.home.homeDirectory}/Documents/Work/Editing/aftershoot-cloud/env/dev/mongo-reader/app.env", "${config.home.homeDirectory}/Documents/Work/Editing/aftershoot-cloud/dist/mcp-servers/mongo-reader"],
            "disabled": true
          },
          "stage-mongo-reader": {
            "command": "${config.home.homeDirectory}/.npm-global/bin/env-cmd",
            "args": ["-f", "${config.home.homeDirectory}/Documents/Work/Editing/aftershoot-cloud/env/dev/mongo-reader/stage-app.env", "${config.home.homeDirectory}/Documents/Work/Editing/aftershoot-cloud/dist/mcp-servers/mongo-reader"],
            "disabled": true
          },
          "sentry-reader": {
            "command": "${config.home.homeDirectory}/.npm-global/bin/env-cmd",
            "args": ["-f", "${config.home.homeDirectory}/Documents/Work/Editing/aftershoot-cloud/env/dev/sentry-reader/app.env", "${config.home.homeDirectory}/Documents/Work/Editing/aftershoot-cloud/dist/mcp-servers/sentry-reader"],
            "disabled": true
          },
          "arxiv": {
            "command": "arxiv-mcp-server",
            "args": [],
            "env": {"ARXIV_STORAGE_PATH": "~/Downloads/papers"}
          }
        }
      }
      EOF
    '';

  home.file.".config/opencode/package.json" = {
    source = ../../opencode/package.json;
  };

  home.file.".config/gitleaks/config.toml" = {
    text = ''
      [extend]
      useDefault = true

      [[rules]]
      description = "Chutes API Key"
      id = "chutes-api-key"
      regex = 'cpk_[0-9a-f]{32}\.[0-9a-f]{32}\.[0-9a-zA-Z]{32}'
      tags = ["api", "chutes"]

      [[rules]]
      description = "DeepSeek API Key"
      id = "deepseek-api-key"
      regex = 'sk-[a-f0-9]{32}'
      tags = ["api", "deepseek"]

      [[rules]]
      description = "GLHF API Key"
      id = "glhf-api-key"
      regex = 'glhf_[a-f0-9]{32}=?'
      tags = ["api", "glhf"]

      [[rules]]
      description = "Groq API Key"
      id = "groq-api-key"
      regex = 'gsk_[a-zA-Z0-9]{52}'
      tags = ["api", "groq"]

      [[rules]]
      description = "Jina AI API Key"
      id = "jina-api-key"
      regex = 'jina_[a-zA-Z0-9]{60}'
      tags = ["api", "jina"]

      [[rules]]
      description = "NanoGPT API Key"
      id = "nanogpt-api-key"
      regex = 'sk-nano-[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
      tags = ["api", "nanogpt"]

      [[rules]]
      description = "OpenRouter API Key"
      id = "openrouter-api-key"
      regex = 'sk-or-v1-[a-f0-9]{64}'
      tags = ["api", "openrouter"]

      [[rules]]
      description = "Tavily API Key"
      id = "tavily-api-key"
      regex = 'tvly-[a-z]+-[A-Za-z0-9]{32}'
      tags = ["api", "tavily"]

      [[rules]]
      description = "RunPod API Key"
      id = "runpod-api-key"
      regex = 'rpa_[A-Za-z0-9]{44,}'
      tags = ["api", "runpod"]
    '';
  };

  # Shell configuration
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ll = lib.mkForce "ls -la";
      ".." = "cd ..";
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
    shellAliases = {
      ll = lib.mkForce "ls -la";
      ".." = "cd ..";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Linux-specific activation
  home.activation.noisetorch-caps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    /usr/bin/sudo ${pkgs.libcap}/bin/setcap 'CAP_SYS_RESOURCE+ep' "${pkgs.noisetorch}/bin/noisetorch"
  '';

  # Enable generic Linux target
  targets.genericLinux.enable = true;

  # XDG configuration
  xdg.enable = true;

  # Systemd user services
  systemd.user.services.vicinae = {
    Unit = {
      Description = "Vicinae Launcher Server";
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.vicinae}/bin/vicinae server";
      Restart = "on-failure";
      RestartSec = "3s";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  wayland.windowManager.hyprland.systemd.enable = true;
}

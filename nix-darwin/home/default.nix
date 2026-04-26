{ pkgs, lib, config, ... }:
{
  imports = [
    ./programs
  ];
  home.stateVersion = "23.11";
  home.packages = [
    pkgs.neovim
    pkgs.fastfetch
    pkgs.exiftool
    pkgs.python313
    pkgs.python313Packages.pip
    pkgs.opentofu
    (pkgs.google-cloud-sdk.withExtraComponents [pkgs.google-cloud-sdk.components.kubectl pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin])
    pkgs.golangci-lint
    pkgs.nightlight
    pkgs.nodejs_24
    pkgs.tree-sitter
    pkgs.spotify
    pkgs.slack
    pkgs.discord
    pkgs.raycast
    pkgs.google-cloud-sql-proxy
    pkgs.dbeaver-bin
    pkgs.gopls
    pkgs.rustup
    pkgs.mongodb-compass
    pkgs.brave
    pkgs.ffmpeg_6-headless
    pkgs.exempi
    pkgs.sqlc
    pkgs.github-copilot-cli
    pkgs.p7zip
    pkgs.vi-mongo
    pkgs.tabiew
    pkgs.just
    pkgs.lazysql
    pkgs.packer
    pkgs.webtorrent_desktop
    pkgs.moonlight-qt
    pkgs.gitleaks
    pkgs.monitorcontrol
    pkgs.terminal-notifier
  ];

  launchd.agents.turn-on-night-shift = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.nightlight}/bin/nightlight"
        "on"
      ];
      RunAtLoad = true;
    };
  };

  home.activation.writeMutableAiConfigs =
    let
      statuslineScript = ''
        #!/usr/bin/env bash
        # Claude Code status line - mirrors Starship config (nix-darwin/home/programs/starship.nix)

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
            ;;
          *)
            title=$(printf '%s' "$input" | jq -r '.title // "Claude Code"')
            message=$(printf '%s' "$input" | jq -r '.message // ""')
            ;;
        esac
        terminal-notifier -title "$title" -message "$message" -group claude-code
      '';

      claudeSettings = ''
        {
          "$schema": "https://json.schemastore.org/claude-code-settings.json",
          "viewMode": "verbose",
          "statusLine": {
            "type": "command",
            "command": "bash /Users/illusion/.claude/statusline-command.sh"
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
      '';

      claudeConfig = ''
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
              "command": "/opt/homebrew/bin/npx",
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
      '';

      opencodePackageJson = ''
        {
          "private": true,
          "type": "module",
          "dependencies": {
            "@opencode-ai/plugin": "latest"
          }
        }
      '';

    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/.config/opencode"
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
      ${claudeSettings}
      EOF

      rm -f "$HOME/.claude.json"
      cat <<'EOF' > "$HOME/.claude.json"
      ${claudeConfig}
      EOF

      rm -f "$HOME/.config/opencode/package.json"
      cat <<'EOF' > "$HOME/.config/opencode/package.json"
      ${opencodePackageJson}
      EOF

    '';
}

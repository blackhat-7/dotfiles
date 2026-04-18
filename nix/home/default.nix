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
    neofetch
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
    };
    extraConfig = {
      core.hooksPath = "~/.githooks";
    };
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

  home.activation.writeMutableAiConfigs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rm -f "$HOME/.claude.json"
    cat <<'EOF' > "$HOME/.claude.json"
    {
      "mcpServers": {
        "ai-tools": {
          "command": "ai-tools-mcp",
          "args": []
        },
        "playwright": {
          "command": "npx",
          "args": ["@playwright/mcp@latest"],
          "disabled": true
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

  home.file.".config/opencode/tools/reddit.ts" = {
    source = ../../opencode/tools/reddit.ts;
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

{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: {

  imports = [
    ./git.nix
    ./kitty.nix
    ./tmux.nix
    ./fish.nix
    ./starship.nix
    ./aerospace.nix
    inputs.nix-index-database.homeModules.nix-index
  ];

  programs = {
    bash.enable = true;
    # zsh.enable = true;
    atuin.enable = true;
    aichat = {
      enable = true;
      settings = {
        model = "chutes:openai/gpt-oss-120b-TEE";
        clients = [
          # {
          #   type = "openai-compatible";
          #   name = "pc";
          #   api_base = "http://100.64.0.1:7000/v1";
          #   api_key = "";
          #   models = [
          #     {
          #       name = "openai/gpt-oss-20b";
          #       supports_function_calling = true;
          #       use_tools = "web_search";
          #     }
          #   ];
          # }
          {
            type = "openai-compatible";
            name = "chutes";
            api_base = "https://llm.chutes.ai/v1";
            models = [
              {
                name = "openai/gpt-oss-120b-TEE";
                supports_function_calling = true;
                strip_reasoning_contents = true;
                patch = {
                  body = {
                    reasoning_effort = "low";
                  };
                };
              }
              {
                name = "Qwen/Qwen3-Next-80B-A3B-Instruct";
                supports_function_calling = true;
              }
            ];
          }
        ];
      };
    };
    direnv = {
      enable = true;
      package = pkgs.direnv.overrideAttrs (old: {
        env = (old.env or {}) // {
          CGO_ENABLED = "1";
        };
      });
      nix-direnv.enable = true;
    };
    btop.enable = true;
    zoxide.enable = true;
    tmux.enable = true;
    lsd.enable = true;
    jq.enable = true;
    bat.enable = true;
    fzf.enable = true;
    ripgrep.enable = true;
    # zed-editor.enable = true;
    vscode = {
      enable = true;
      package = pkgs.vscode.overrideAttrs (old: {
        # nixpkgs 13043924 regressed on Darwin by adding glibc to vscode's preFixup path.
        preFixup = if pkgs.stdenv.hostPlatform.isDarwin then "" else old.preFixup or "";
      });
    };
    gh.enable = true;
    uv.enable = true;
    television.enable = true;
    fd.enable = true;
    nix-index-database.comma.enable = true;
    nix-index = {
      enable = true;
      enableFishIntegration = true;
    };
    # yt-dlp.enable = true;
    carapace = {
      enable = true;
      enableFishIntegration = true;
    };
    obsidian.enable = true;
    zellij.enable = true;
    yazi = {
      enable = true;
      shellWrapperName = "y";
    };
    # opencode.enable = true;
    claude-code.enable = true;
    bun.enable = true;
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

  home.activation.install-uv-tools = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    tools="
      basedpyright
      ruff
      arxiv-mcp-server
    "
    for tool in $tools; do
      echo "Installing $tool with uv..."
      ${pkgs.uv}/bin/uv tool install $tool
    done
  '';

  home.activation.install-pi = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${pkgs.nodejs_24}/bin:$PATH"
    npm_bin="${config.home.homeDirectory}/.npm-global/bin"
    npm i -g @mariozechner/pi-coding-agent || true
    "$npm_bin/pi" install npm:pi-mcp-adapter || true
    "$npm_bin/pi" install npm:permission-pi || true

    # permission-pi plays /System/Library/Sounds/Funk.aiff (or terminal bell) for prompts.
    # Replace that with a silent macOS notification banner, similar to Claude Code alerts.
    permission_ext="${config.home.homeDirectory}/.npm-global/lib/node_modules/permission-pi/permission.ts"
    if [[ -f "$permission_ext" ]]; then
      ${pkgs.python313}/bin/python - <<'PY'
import re
from pathlib import Path

path = Path.home() / ".npm-global/lib/node_modules/permission-pi/permission.ts"
text = path.read_text()
new = """function playPermissionSound(): void {
  if (process.platform !== "darwin") return;

  exec('${pkgs.terminal-notifier}/bin/terminal-notifier -title "Pi" -message "Permission required" -group "pi-permission" 2>/dev/null || true');
}"""
patched = re.sub(
    r"function playPermissionSound\(\): void \{.*?\n\}",
    new,
    text,
    count=1,
    flags=re.S,
)
if patched != text:
    path.write_text(patched)
PY
    fi
  '';
}

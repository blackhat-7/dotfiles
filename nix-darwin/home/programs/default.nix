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
    packages="
      npm:pi-mcp-adapter
      npm:pi-permission-system
      npm:pi-web-access
      npm:pi-subagents
      npm:pi-mermaid
      npm:@juicesharp/rpiv-todo
      npm:@ifi/oh-pi-themes
      npm:pi-rewind
      npm:pi-intercom
    "

    npm i -g @mariozechner/pi-coding-agent beautiful-mermaid || true

    settings="${config.home.homeDirectory}/.pi/agent/settings.json"
    if [ -f "$settings" ]; then
      desired_json=$(printf '%s\n' $packages | ${pkgs.jq}/bin/jq -R . | ${pkgs.jq}/bin/jq -s .)
      ${pkgs.jq}/bin/jq --argjson packages "$desired_json" '.packages = $packages' "$settings" > "$settings.tmp" && mv "$settings.tmp" "$settings"
    fi

    for package in $packages; do
      "$npm_bin/pi" install "$package" || true
    done

    subagents_root="${config.home.homeDirectory}/.npm-global/lib/node_modules/pi-subagents"
    if [ -d "$subagents_root" ]; then
      ${pkgs.python3}/bin/python3 - "$subagents_root" <<'PY'
import pathlib
import sys

root = pathlib.Path(sys.argv[1])

def patch(path, old, new):
    text = path.read_text()
    if new in text:
        return
    if old not in text:
        raise SystemExit(f"Could not apply pi-subagents safety patch to {path}")
    path.write_text(text.replace(old, new))

patch(
    root / "src/runs/shared/pi-args.ts",
    '\tconst env: Record<string, string | undefined> = {};\n\tenv[SUBAGENT_CHILD_ENV] = "1";',
    '\tconst env: Record<string, string | undefined> = {};\n\tenv[SUBAGENT_CHILD_ENV] = "1";\n\tenv.PI_IS_SUBAGENT = "1";',
)
patch(
    root / "src/extension/index.ts",
    '\tconst resetSessionState = (ctx: ExtensionContext) => {\n\t\tstate.baseCwd = ctx.cwd;\n\t\tstate.currentSessionId = resolveCurrentSessionId(ctx.sessionManager);\n\t\tstate.lastUiContext = ctx;',
    '\tconst resetSessionState = (ctx: ExtensionContext) => {\n\t\tstate.baseCwd = ctx.cwd;\n\t\tstate.currentSessionId = resolveCurrentSessionId(ctx.sessionManager);\n\t\tprocess.env.PI_AGENT_ROUTER_PARENT_SESSION_ID = ctx.sessionManager.getSessionId() ?? "";\n\t\tstate.lastUiContext = ctx;',
)
PY
    fi
  '';
}

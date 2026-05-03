{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
{

  imports = [
    ./kitty.nix
    ./tmux.nix
    ./fish.nix
    ./starship.nix
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
    direnv.enable = true;
    direnv.nix-direnv.enable = true;
    btop.enable = true;
    zoxide.enable = true;
    tmux.enable = true;
    lsd.enable = true;
    jq.enable = true;
    bat.enable = true;
    fzf.enable = true;
    ripgrep.enable = true;
    zed-editor.enable = true;
    vscode.enable = true;
    gh.enable = true;
    uv.enable = true;
    television.enable = true;
    fd.enable = true;
    nix-index-database.comma.enable = true;
    nix-index = {
      enable = true;
      enableFishIntegration = true;
    };
    hyprpanel.enable = true;
    yazi = {
      enable = true;
      shellWrapperName = "y";
    };
    feh.enable = true;
    # opencode.enable = true;
    claude-code.enable = true;
  };

  home.activation.install-uv-tools = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # A list of Python packages to install with 'uv tool install'
    tools="
      basedpyright
      ruff
      arxiv-mcp-server
    "
    # Install each tool
    for tool in $tools; do
      echo "Installing $tool with uv..."
      ${pkgs.uv}/bin/uv tool install $tool
    done
  '';

  home.activation.install-pi = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${pkgs.nodejs_24}/bin:$PATH"
    export npm_config_prefix="${config.home.homeDirectory}/.npm-global"
    npm_bin="$npm_config_prefix/bin"
    mkdir -p "$npm_bin"

    npm i -g @mariozechner/pi-coding-agent env-cmd || true
    "$npm_bin/pi" install npm:pi-mcp-adapter || true
    "$npm_bin/pi" install npm:permission-pi || true
    "$npm_bin/pi" install npm:pi-web-access || true
  '';
}

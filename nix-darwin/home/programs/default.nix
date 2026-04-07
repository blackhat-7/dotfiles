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
        model = "chutes/deepseek-ai/DeepSeek-V3.2-TEE";
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
                name = "chutes/deepseek-ai/DeepSeek-V3.2-TEE";
                supports_function_calling = true;
                strip_reasoning_contents = true;
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
    neovim.enable = true;
    # zed-editor.enable = true;
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
}

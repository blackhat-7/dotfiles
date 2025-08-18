{ pkgs, ... }: {

  imports = [
    ./kitty.nix
    ./tmux.nix
    ./fish.nix
    ./starship.nix
  ];

  programs = {
    bash.enable = true;
    # zsh.enable = true;
    atuin.enable = true;
    aichat.enable = true;
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
    neovim.enable = true;
    zed-editor.enable = true;
    vscode.enable = true;
    gh.enable = true;
    uv.enable = true;
    television.enable = true;
    fd.enable = true;
  };
}

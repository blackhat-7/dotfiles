{ pkgs, inputs, ... }:

{
  imports = [
    ./kitty.nix
    ./tmux.nix
    ./fish.nix
    ./starship.nix
  ] ++ (if builtins.hasAttr "homeModules" inputs.nix-index-database
      then [ inputs.nix-index-database.homeModules.nix-index ]
      else []);

  # Common program configurations that work on both platforms
  programs = {
    # Shell utilities
    bash.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    btop.enable = true;
    zoxide.enable = true;
    lsd.enable = true;
    jq.enable = true;
    bat.enable = true;
    fzf.enable = true;
    ripgrep.enable = true;
    fd.enable = true;

    # Development tools
    gh.enable = true;
    neovim.enable = true;

    # Optional: Enable these as needed based on your system
    tmux.enable = true;

    # Conditionally enable programs based on availability in the system
    nix-index = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}

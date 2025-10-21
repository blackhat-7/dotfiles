{ pkgs, config, lib, ... }:

{
  imports = [
    ./programs
  ];

  # Basic home-manager configuration
  home.stateVersion = "23.11";

  # Common packages for all platforms
  home.packages = with pkgs; [
    neofetch
    exiftool
    tailscale
    python311
    python311Packages.pip
    opentofu
    terragrunt
    golangci-lint
    nodejs_24
    gopls
    rustup
    git
    ffmpeg_6-headless
  ];

  # Common git configuration
  programs.git = {
    enable = true;
    userName = "blackhat-7";
    userEmail = "palshaunak7@gmail.com"; # Replace with your actual email
  };

  # Other common configurations for both platforms
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      # Using lib.mkForce to override any conflicts
      ll = lib.mkForce "ls -la";
      ".." = "cd ..";
    };
  };

  # ZSH shell configuration
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;  # Updated to new option name
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = lib.mkForce "ls -la";
      ".." = "cd ..";
    };
  };

  # Fish shell configuration
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

  # Configure direnv for per-directory environment variables
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}

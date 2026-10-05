{ pkgs, ... }:

# Headless Raspberry Pi (Raspberry Pi OS Lite base). Keep this small.
{
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    git
    neovim
    htop
    tmux
    just
    # PC is cabled straight to eth0; raw frame works even without an IP.
    (writeShellScriptBin "wake-pc" ''
      exec sudo ${busybox}/bin/ether-wake -i eth0 74:56:3c:6b:fe:a1
    '')
  ];

  home.sessionVariables.EDITOR = "nvim";

  imports = [ ../home/programs/starship.nix ];

  programs.home-manager.enable = true;
  programs.fish = {
    enable = true;
    generateCompletions = false; # same breakage as the desktop config
  };
  # Login shell stays /bin/bash so SSH still works if nix breaks.
  programs.bash = {
    enable = true;
    initExtra = ''
      if [[ $- == *i* && -z $BASH_EXECUTION_STRING ]] && command -v fish >/dev/null; then
        exec fish
      fi
    '';
  };
}

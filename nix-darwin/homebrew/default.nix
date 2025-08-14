{ ... }: {
  homebrew = {
    enable = true;
    global.autoUpdate = true;
    casks = [
      "zen"
      "docker"
      "hammerspoon"
      "linear-linear"
    ];
  };
}

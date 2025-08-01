{ ... }: {
  homebrew = {
    enable = true;
    global.autoUpdate = true;
    casks = [
      "raycast"
      "zen"
      "docker"
    ];
  };
}

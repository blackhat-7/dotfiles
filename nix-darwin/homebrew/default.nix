{ ... }: {
  homebrew = {
    enable = true;
    global.autoUpdate = true;
    casks = [
      "zen"
      "docker-desktop"
      "linear"
      "chromium"
      "wine-stable"
      "zed"
      "kitty"
    ];
  };
}

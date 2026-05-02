{ ... }: {
  homebrew = {
    enable = true;
    global.autoUpdate = true;
    casks = [
      "zen"
      "docker"
      "linear-linear"
      "chromium"
      "krisp"
      "wine-stable"
      "whisky"
      "ollama"
      "zed"
      "element"
      "obs"
    ];
  };
}

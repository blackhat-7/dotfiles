{ ... }: {
  homebrew = {
    enable = true;
    global.autoUpdate = true;
    onActivation.autoUpdate = true;
    taps = [
      "stablyai/orca"
    ];
    casks = [
      "zen"
      "docker-desktop"
      "linear"
      "chromium"
      "wine-stable"
      "zed"
      "kitty"
      "chatgpt"
      "stablyai/orca/orca"
    ];
  };
}

{ ... }: {
  homebrew = {
    enable = true;
    global.autoUpdate = true;
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    taps = [
      "stablyai/orca"
    ];
    brews = [
      "atuin"
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
      "t3-code"
      "superwhisper"
    ];
  };
}

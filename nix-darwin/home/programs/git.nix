{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "blackhat-7";
      user.email = "palshaunak7@gmail.com";
      core.hooksPath = "~/.githooks";
      push.autoSetupRemote = true;
      rerere.enabled = true;
    };
  };

  home.file.".githooks/pre-commit" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      exec gitleaks protect --staged --verbose --config "$HOME/.config/gitleaks/config.toml"
    '';
  };

  home.file.".config/gitleaks/config.toml" = {
    text = ''
      [extend]
      useDefault = true

      [[rules]]
      description = "Chutes API Key"
      id = "chutes-api-key"
      regex = "cpk_[0-9a-f]{32}\\.[0-9a-f]{32}\\.[0-9a-zA-Z]{32}"
      tags = ["api", "chutes"]
    '';
  };
}

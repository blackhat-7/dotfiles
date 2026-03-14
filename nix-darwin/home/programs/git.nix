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
      exec gitleaks protect --staged --verbose
    '';
  };
}

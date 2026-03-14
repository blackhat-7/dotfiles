{ ... }:
{
  programs.git = {
    enable = true;
    extraConfig = {
      core.hooksPath = "~/.githooks";
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

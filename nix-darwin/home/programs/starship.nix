{ pkgs, ... }: {
  programs.starship = {
    enable = true;
    settings = {
      format = "$directory$git_branch$git_status$python$cmd_duration$line_break$character";
      add_newline = true;

      directory = {
        truncation_length = 3;
        style = "cyan bold";
        format = "[$path]($style) ";
        truncation_symbol = "…/";
      };

      git_branch = {
        symbol = "";
        style = "bold purple";
        format = "on [$symbol$branch]($style) ";
      };

      git_status = {
        style = "bold red";
        format = "([\\[$all_status$ahead_behind\\]]($style) )";
      };

      python = {
        pyenv_version_name = false;
        style = "yellow bold";
        format = "via [$symbol($virtualenv)]($style) ";
      };

      cmd_duration = {
        format = "took [$duration]($style) ";
        style = "yellow bold";
        min_time = 5000;
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };
}

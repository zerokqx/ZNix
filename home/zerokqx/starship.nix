{ lib, ... }:
{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;

    settings = {
      add_newline = false;

      format = "$directory$git_branch$python$character";

      directory = {
        format = "[󰉋 $path]($style) ";
        style = "bold blue";
        truncation_length = 4;
        truncate_to_repo = false;
      };

      git_branch = {
        symbol = " ";
        style = "bold purple";
        format = "[($branch)]($style) ";
      };

      python = {
        disabled = false;
        symbol = " ";
        format = "[($symbol$virtualenv)]($style) ";
        style = "bold yellow";
      };

      character = {
        success_symbol = "[❯](bold green) ";
        error_symbol = "[❯](bold red) ";
        vimcmd_symbol = "[❮](bold yellow) ";
      };
    };
  };
}

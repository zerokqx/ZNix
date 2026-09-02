{ lib, ... }:
{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;

    settings = {
      add_newline = false;

      format = "$directory$git_branch$character";

      directory = {
        style = "bold blue";
        truncation_length = 4;
        truncate_to_repo = false;
        format = "[$path]($style) ";
      };

      git_branch = {
        symbol = "";
        style = "bold purple";
        format = "[($branch)]($style) ";
      };

      character = {
        success_symbol = "[❯](bold green) ";
        error_symbol = "[❯](bold red) ";
        vimcmd_symbol = "[❮](bold yellow) ";
      };
    };
  };
}

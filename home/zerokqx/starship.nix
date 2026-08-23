{ lib, ... }:
{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;

    settings = {
      add_newline = false;

      format = "$username$hostname$directory$git_branch$git_status$nix_shell$cmd_duration$character";

      username = {
        show_always = false;
        style_user = "bold blue";
        style_root = "bold red";
        format = "[$user]($style)";
      };

      hostname = {
        ssh_only = true;
        style = "bold cyan";
        format = "[@$hostname]($style) ";
      };

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

      git_status = {
        style = "yellow";
        format = "[$all_status$ahead_behind]($style) ";
        conflicted = "=";
        ahead = ">";
        behind = "<";
        diverged = "<>";
        untracked = "?";
        modified = "*";
        staged = "+";
        renamed = "»";
        deleted = "x";
      };

      nix_shell = {
        style = "bold cyan";
        format = "[nix:$state]($style) ";
      };

      cmd_duration = {
        min_time = 2000;
        style = "bright-black";
        format = "[took $duration]($style) ";
      };

      character = {
        success_symbol = "[❯](bold green) ";
        error_symbol = "[❯](bold red) ";
        vimcmd_symbol = "[❮](bold yellow) ";
      };
    };
  };
}

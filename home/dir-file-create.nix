{ config, ... }:
{

  home.file."${config.home.homeDirectory}/projects/.keep" = {
    text = "";
  };
}

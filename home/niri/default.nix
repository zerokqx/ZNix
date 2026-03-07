{ config, ... }:
{
  home.file."${config.home.homeDirectory}/.config/niri/config.kdl".source = ./config.kdl;
}

{ config, pkgs, ... }:

{
  services.mako = {
    enable = true;

    settings = {
      # background-color = "#000000";

      icons = false;
      actions = true;
      max-visible = 3;
      max-history = 50;
      # text-color = "#ffffff";
      # border-color = "#00FF00";

      border-size = 2;
      padding = 10;

      default-timeout = 5000;

      anchor = "top-right";
      width = 360;
      height = 110;

      layer = "overlay";
    };
  };
}

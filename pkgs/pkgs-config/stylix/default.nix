{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  stylix = {
    enable = false;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";

    autoEnable = false;
    targets.gnome.enable = false;
  };

  # home-manager.sharedModules = [
  #   {
  #     stylix = {
  #       enable = false;
  #       autoEnable = false;
  #       targets = {
  #         opencode.enable = false;
  #       };
  #     };
  #   }
  # ];
}

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

    targets = {
      alacritty.colors.enable = true;
      gtk.colors.enable = true;
    };
  };

}

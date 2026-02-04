{ pkgs, config, ... }:
{
  stylix = {
    enable = true;
    polarity = "dark";
    cursor = {
      name = "MacOS";
      size = 16;
      package = pkgs.apple-cursor;
    };
    icons = {
      enable = true;
      package = pkgs.whitesur-icon-theme;
      dark = "WhiteSur-dark";
      light = "WhiteSur-light";
    };
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
    autoEnable = true;
    targets = {

      lazygit.enable = true;
      fzf.enable = true;
      btop.enable = true;
      opencode.enable = true;
      zathura.enable = true;
      noctalia-shell.enable = true;
      firefox.enable = true;
      firefox.profileNames = [ "default" ];
      alacritty = {
        colors.enable = true;
        fonts.enable = false;
      };
      gtk.enable = true;

    };
  };
}

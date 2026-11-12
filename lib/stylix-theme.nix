{ pkgs }:
{
  base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
  polarity = "dark";
  fonts = {
    monospace = {
      package = pkgs.nerd-fonts.fira-code;
      name = "FiraCode Nerd Font";
    };
    sansSerif = {
      package = pkgs.sn-pro;
      name = "SN Pro";
    };
    serif = {
      package = pkgs.sn-pro;
      name = "SN Pro";
    };
    emoji = {
      package = pkgs.noto-fonts-color-emoji;
      name = "Noto Color Emoji";
    };
    sizes = {
      terminal = 14;
      applications = 13;
      desktop = 12;
      popups = 13;
    };
  };
}

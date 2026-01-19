{
  pkgs,
  ...
}:
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
      dark = "WhiteSur-dark";
      light = "WhiteSur-light";
      package = pkgs.whitesur-icon-theme;
      enable = true;
    };
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    autoEnable = true;
    targets = {
      noctalia-shell.enable = true;
      firefox.enable = true;
      firefox.profileNames = [
        "default"
      ];
      alacritty = {
        colors = {
          enable = true;
        };
        fonts = {
          enable = false;
        };
      };
      spicetify.colors.enable = true;
      gtk.colors.enable = true;
      nixvim = {
        opacity.enable = true;
        transparentBackground = {
          main = true;
          numberLine = true;
          signColumn = true;
        };
      };
    };

    # fonts = {
    #   serif = {
    #     package = pkgs.maple-mono.NF;
    #     name = "Maple Mono NF";
    #   };
    #
    #   sansSerif = {
    #     package = pkgs.maple-mono.NF;
    #     name = "Maple Mono NF";
    #   };
    #
    #   monospace = {
    #     package = pkgs.maple-mono."NF-CN";
    #     name = "Maple Mono NF CN";
    #   };
    #
    # };
  };
}

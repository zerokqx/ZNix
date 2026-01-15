{
  pkgs,
  ...
}:
{

  stylix = {
    enable = true;
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
          enable = false; # отключить шрифты Stylix для Alacritty
        };
      };
      gtk.colors.enable = true;
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

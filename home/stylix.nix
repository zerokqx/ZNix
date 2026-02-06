{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.theme;
in
{
  options.theme = {
    polarity = lib.mkOption {
      type = lib.types.enum [
        "dark"
        "light"
      ];
      default = "dark";
    };

    cursorPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.apple-cursor;
    };

    icons = lib.mkOption {
      type = lib.types.submodule {
        options = {
          package = lib.mkOption {
            type = lib.types.package;
            default = pkgs.whitesur-icon-theme;
          };
          dark = lib.mkOption {
            type = lib.types.str;
            default = "WhiteSur-dark";
          };
          light = lib.mkOption {
            type = lib.types.str;
            default = "WhiteSur-light";
          };
        };
      };
      default = { };
    };
  };

  config = {
    stylix = {
      enable = true;
      polarity = cfg.polarity;

      cursor = {
        name = "MacOS";
        size = 16;
        package = cfg.cursorPackage;
      };

      icons = {
        enable = true;
        package = cfg.icons.package;
        dark = cfg.icons.dark;
        light = cfg.icons.light;
      };

      base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";

      autoEnable = true;

      targets = {
        lazygit.enable = true;
        fzf.enable = true;
        btop.enable = true;
        opencode.enable = true;
        zathura.enable = true;
        noctalia-shell.enable = true;

        firefox = {
          enable = true;
          profileNames = [ "default" ];
        };

        alacritty = {
          colors.enable = true;
          fonts.enable = false;
        };

        gtk.enable = true;
      };
    };
  };
}

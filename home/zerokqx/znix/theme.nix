{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.znix.theme;
in
{
  options.znix.theme = {
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
            default = pkgs.papirus-icon-theme;
          };
          dark = lib.mkOption {
            type = lib.types.str;
            default = "Papirus-Dark";
          };
          light = lib.mkOption {
            type = lib.types.str;
            default = "Papirus-Light";
          };
        };
      };
      default = { };
    };
  };

  config = {
    home.packages = [ cfg.icons.package ];

    stylix = {
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

      enable = true;
      polarity = cfg.polarity;

      cursor = {
        name = "macOS";
        size = 24;
        package = cfg.cursorPackage;
      };

      icons = {
        enable = true;
        package = cfg.icons.package;
        dark = cfg.icons.dark;
        light = cfg.icons.light;
      };

      base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes//tokyo-night-dark.yaml";

      autoEnable = true;

      targets = {
        nixvim = {
          enable = true;
          transparentBackground = {
            main = false;
            numberLine = false;
            signColumn = false;
          };
        };
        xresources.enable = false;
        lazygit.enable = true;
        fzf.enable = true;
        btop.enable = true;
        opencode.enable = true;
        zathura.enable = true;
        noctalia-shell.enable = true;
        firefox = {
          enable = true;
          colors.enable = true;
          colorTheme.enable = true;
          profileNames = [ config.znix.browser.profile ];
        };

        foot = {
          enable = true;
        };

        gtk.enable = true;
      };
    };

  };
}

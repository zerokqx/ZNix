{
  pkgs,
  lib,
  config,
  osConfig ? { },
  ...
}:
let
  cfg = config.znix.theme;
  sharedTheme = import ../../../lib/stylix-theme.nix { inherit pkgs; };
  systemTheme = osConfig.stylix or { };
in
{
  options.znix.theme = {
    polarity = lib.mkOption {
      type = lib.types.enum [
        "dark"
        "light"
      ];
      default =
        if
          lib.elem (systemTheme.polarity or "either") [
            "dark"
            "light"
          ]
        then
          systemTheme.polarity
        else
          sharedTheme.polarity;
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
    programs.zellij.enable = true;

    stylix = lib.mkMerge [
      # При встроенном Home Manager системные значения Stylix имеют приоритет.
      (lib.mkOverride 1100 sharedTheme)
      (lib.optionalAttrs (systemTheme.enable or false) (
        lib.mkDefault {
          inherit (systemTheme)
            base16Scheme
            image
            imageScalingMode
            opacity
            override
            ;
          fonts = removeAttrs systemTheme.fonts [ "packages" ];
        }
      ))
      {
        enable = lib.mkDefault true;
        polarity = lib.mkDefault cfg.polarity;

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

        autoEnable = true;

        targets.nixvim.enable = false;

        targets = {
          xresources.enable = false;
          lazygit.enable = true;
          fzf.enable = true;
          btop.enable = true;
          opencode.enable = true;
          zathura.enable = true;
          zellij.enable = true;

          foot = {
            enable = true;
          };

          gtk.enable = true;
        };
      }
    ];

  };
}

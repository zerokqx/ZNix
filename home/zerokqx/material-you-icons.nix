{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.znix.theme;
  colors = config.lib.stylix.colors.withHashtag;
  enable = cfg.materialYouIcons.enable && config.stylix.enable;
  palette = pkgs.writeText "material-you-icons-palette.json" (
    builtins.toJSON {
      background = colors.base00;
      container = colors.base01;
      glyph = colors.base0D;
    }
  );
  sourceTheme = if cfg.polarity == "dark" then cfg.icons.dark else cfg.icons.light;
  renderer = pkgs.callPackage ../../pkgs/material-you-icons {
    inherit (cfg.materialYouIcons) rocm gfxOverride;
  };
  themeDir = "${config.xdg.dataHome}/icons/MaterialYou";
  installIcons = pkgs.writeShellScript "install-material-you-icons" ''
    export XDG_DATA_HOME=${lib.escapeShellArg config.xdg.dataHome}
    export XDG_DATA_DIRS=${lib.escapeShellArg "${config.home.profileDirectory}/share:${cfg.icons.package}/share"}:"''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
    exec ${lib.escapeShellArg "${renderer}/bin/render-icon"} install \
      --theme-dir ${lib.escapeShellArg themeDir} \
      --inherits ${lib.escapeShellArg sourceTheme} \
      --palette ${lib.escapeShellArg (toString palette)} \
      --device ${if cfg.materialYouIcons.rocm then "cuda" else "cpu"}
  '';
in
{
  options.znix.theme.materialYouIcons = {
    enable = lib.mkEnableOption "Material You generated icon theme" // {
      default = true;
    };
    rocm = lib.mkEnableOption "ROCm acceleration for Material You icon generation";
    gfxOverride = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional HSA GFX version override for an older Radeon GPU.";
    };
  };

  config = lib.mkIf enable {
    systemd.user.services.material-you-icons = {
      Unit = {
        Description = "Generate the Material You icon theme from Stylix colors";
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "exec";
        RemainAfterExit = true;
        ExecStart = "${installIcons}";
        Nice = 10;
        Environment = [
          "OMP_NUM_THREADS=2"
          "MKL_NUM_THREADS=2"
        ];
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };

    # Stylix selects the generated theme by name. Papirus remains installed as
    # the source theme and fallback for icons the generator does not replace.
    stylix.icons.dark = lib.mkForce "MaterialYou";
    stylix.icons.light = lib.mkForce "MaterialYou";
    gtk.iconTheme.name = lib.mkForce "MaterialYou";
    home.sessionVariables.QS_ICON_THEME = "MaterialYou";
    programs.caelestia.systemd.environment = lib.mkIf (config.programs.caelestia.enable or false) [
      "QS_ICON_THEME=MaterialYou"
    ];
  };
}

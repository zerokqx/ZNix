{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (config) stylix;
  inherit (config.lib.stylix.colors) withHashtag;
  liquid = config.znix.sddm.liquid;
  liquidEnabled = config.services.displayManager.sddm.enable && stylix.enable && liquid.enable;
  liquidBackground = pkgs.callPackage ../pkgs/liquid-background.nix {
    colors =
      if liquid.colors == null then
        with withHashtag;
        [
          base00
          base02
          base0E
          base0D
          base0C
        ]
      else
        liquid.colors;
  };
  sharedTheme = import ../lib/stylix-theme.nix { inherit pkgs; };
  themeConfig = (pkgs.formats.ini { }).generate "znix-sddm-theme.conf" {
    General = {
      background = withHashtag.base00;
      surface = withHashtag.base01;
      field = withHashtag.base02;
      border = withHashtag.base03;
      foreground = withHashtag.base05;
      accent = withHashtag.base0D;
      secondaryAccent = withHashtag.base0C;
      error = withHashtag.base08;
      fontFamily = stylix.fonts.sansSerif.name;
      fontSize = stylix.fonts.sizes.desktop;
      wallpaper = if stylix.image == null then "" else toString stylix.image;
      video = lib.optionalString liquidEnabled "${liquidBackground}/liquid.mp4";
      videoPoster = lib.optionalString liquidEnabled "${liquidBackground}/poster.png";
      surfaceOpacity = lib.max 0.92 stylix.opacity.popups;
    };
  };
  theme = pkgs.runCommand "znix-sddm-theme" { } ''
    mkdir -p "$out/share/sddm/themes/znix"
    cp ${./sddm-theme}/* "$out/share/sddm/themes/znix/"
    ln -s ${themeConfig} "$out/share/sddm/themes/znix/theme.conf"
  '';
  u2f = config.security.pam.u2f;
in
{
  imports = [ inputs.stylix.nixosModules.stylix ];

  options.znix.sddm.liquid = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Show the generated liquid background in the Stylix SDDM theme.";
    };
    colors = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.addCheck (lib.types.listOf (lib.types.strMatching "#[0-9a-fA-F]{6}")) (
          colors: builtins.length colors >= 2 && builtins.length colors <= 6
        )
      );
      default = null;
      description = "Liquid background palette from dark to light. Null uses the Stylix palette.";
    };
  };

  config = {
    system.build = lib.optionalAttrs liquidEnabled { sddmLiquidBackground = liquidBackground; };

    stylix = lib.mkMerge [
      (lib.mkDefault sharedTheme)
      {
        enable = lib.mkDefault true;
        autoEnable = false;
        # Stylix уже подключён явно в lib/home-modules.nix.
        homeManagerIntegration.autoImport = false;
      }
    ];

    services.displayManager = {
      defaultSession = lib.mkDefault "hyprland-uwsm";
      sddm = {
        enable = true;
        wayland.enable = true;
        extraPackages = lib.optionals liquidEnabled [ pkgs.kdePackages.qtmultimedia ];
        theme = lib.mkIf stylix.enable "${theme}/share/sddm/themes/znix";
      };
    };

    fonts.packages = lib.mkIf stylix.enable [ stylix.fonts.sansSerif.package ];

    # У SDDM собственный PAM-стек. Сохраняем U2F до парольной проверки, как в Ly.
    security.pam.services.sddm = {
      u2f.enable = true;
      rules.auth.u2f = {
        enable = config.security.pam.services.sddm.u2f.enable;
        order = config.security.pam.services.sddm.rules.auth.login.order - 10;
        control = config.security.pam.services.sddm.u2f.control;
        modulePath = "${pkgs.pam_u2f}/lib/security/pam_u2f.so";
        inherit (u2f) settings;
      };
    };
  };
}

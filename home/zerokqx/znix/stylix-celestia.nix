{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config) stylix;
  inherit (config.lib.stylix) colors;
  cfg = stylix.targets.celestia;
  scheme = {
    name = "stylix";
    flavour = "base16";
    mode =
      if stylix.polarity == "either" then
        (if (colors.variant or "dark") == "light" then "light" else "dark")
      else
        stylix.polarity;
    variant = "tonalspot";
    inherit (cfg) colours;
  };
  schemeFile = pkgs.writeText "caelestia-stylix-scheme.json" (builtins.toJSON scheme);
  inherit (stylix.fonts) sizes;
  fontFamily = lib.mkDefault stylix.fonts.sansSerif.name;
  defaultColours = with colors; {
    primary_paletteKeyColor = base0D;
    secondary_paletteKeyColor = base0C;
    tertiary_paletteKeyColor = base0E;
    neutral_paletteKeyColor = base03;
    neutral_variant_paletteKeyColor = base04;

    background = base00;
    onBackground = base05;
    surface = base00;
    surfaceDim = base00;
    surfaceBright = base02;
    surfaceContainerLowest = base00;
    surfaceContainerLow = base01;
    surfaceContainer = base01;
    surfaceContainerHigh = base02;
    surfaceContainerHighest = base02;
    onSurface = base06;
    surfaceVariant = base02;
    onSurfaceVariant = base05;
    inverseSurface = base05;
    inverseOnSurface = base00;
    outline = base04;
    outlineVariant = base03;
    shadow = base00;
    scrim = base00;
    surfaceTint = base0D;

    primary = base0D;
    onPrimary = base00;
    primaryContainer = base02;
    onPrimaryContainer = base0D;
    inversePrimary = base0D;
    secondary = base0C;
    onSecondary = base00;
    secondaryContainer = base02;
    onSecondaryContainer = base0C;
    tertiary = base0E;
    onTertiary = base00;
    tertiaryContainer = base02;
    onTertiaryContainer = base0E;
    error = base08;
    onError = base00;
    errorContainer = base02;
    onErrorContainer = base08;
    success = base0B;
    onSuccess = base00;
    successContainer = base02;
    onSuccessContainer = base0B;

    primaryFixed = base0D;
    primaryFixedDim = base0D;
    onPrimaryFixed = base00;
    onPrimaryFixedVariant = base00;
    secondaryFixed = base0C;
    secondaryFixedDim = base0C;
    onSecondaryFixed = base00;
    onSecondaryFixedVariant = base00;
    tertiaryFixed = base0E;
    tertiaryFixedDim = base0E;
    onTertiaryFixed = base00;
    onTertiaryFixedVariant = base00;

    term0 = base00;
    term1 = base08;
    term2 = base0B;
    term3 = base0A;
    term4 = base0D;
    term5 = base0E;
    term6 = base0C;
    term7 = base05;
    term8 = base03;
    term9 = base08;
    term10 = base0B;
    term11 = base0A;
    term12 = base0D;
    term13 = base0E;
    term14 = base0C;
    term15 = base07;
  };
in
{
  options.stylix.targets.celestia = {
    enable = config.lib.stylix.mkEnableTarget "Caelestia Shell" true;
    colours = lib.mkOption {
      type = lib.types.attrsOf (lib.types.strMatching "[0-9a-fA-F]{6}");
      default = { };
      description = "Переопределения цветовых ролей Caelestia в формате RRGGBB без #.";
    };
  };

  config = lib.mkIf (stylix.enable && cfg.enable && (config.programs.caelestia.enable or false)) {
    stylix.targets.celestia.colours = lib.mapAttrs (_: lib.mkDefault) defaultColours;

    programs.caelestia = {
      settings = {
        appearance = {
          font = {
            headline.family = fontFamily;
            title.family = fontFamily;
            clock = fontFamily;
            body = {
              family = fontFamily;
              medium.size = lib.mkDefault sizes.applications;
              small.size = lib.mkDefault sizes.desktop;
            };
            label = {
              family = fontFamily;
              medium.size = lib.mkDefault sizes.desktop;
            };
            mono = {
              family = lib.mkDefault stylix.fonts.monospace.name;
              medium.size = lib.mkDefault sizes.terminal;
            };
          };
          transparency = {
            enabled = lib.mkDefault (stylix.opacity.desktop < 1.0 || stylix.opacity.popups < 1.0);
            base = lib.mkDefault stylix.opacity.desktop;
            layers = lib.mkDefault stylix.opacity.popups;
          };
        };
        services.smartScheme = lib.mkDefault false;
      };

      cli.settings.theme = lib.genAttrs [
        "enableTerm"
        "enableHypr"
        "enableDiscord"
        "enableSpicetify"
        "enablePandora"
        "enableFuzzel"
        "enableBtop"
        "enableNvtop"
        "enableHtop"
        "enableGtk"
        "enableQt"
        "enableWarp"
        "enableChromium"
        "enableZed"
        "enableCava"
      ] (_: lib.mkDefault false);
    };

    wayland.windowManager.hyprland.settings.env = [
      "CAELESTIA_STYLIX_SCHEME,${schemeFile}"
    ]
    ++ lib.optional (stylix.image != null) "CAELESTIA_STYLIX_WALLPAPER,${stylix.image}";
  };
}

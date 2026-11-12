{ pkgs, inputs }:
let
  inherit (pkgs) lib;
  home = inputs.self.homeConfigurations.zerokqx;
  config = home.config;
  withOverrides = overrides: (home.extendModules { modules = [ overrides ]; }).config;
  globalOff = withOverrides { stylix.enable = false; };
  targetOff = withOverrides { stylix.targets.celestia.enable = false; };
  dms = withOverrides { programs.caelestia.enable = false; };

  firstWallpaper = pkgs.writeText "first-wallpaper.svg" ''
    <svg xmlns="http://www.w3.org/2000/svg" width="1" height="1"><rect width="1" height="1" fill="#000"/></svg>
  '';
  secondWallpaper = pkgs.writeText "second-wallpaper.svg" ''
    <svg xmlns="http://www.w3.org/2000/svg" width="1" height="1"><rect width="1" height="1" fill="#fff"/></svg>
  '';
  firstImage = withOverrides { stylix.image = firstWallpaper; };
  changed = withOverrides {
    znix.theme.polarity = "light";
    stylix = {
      base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-light-medium.yaml";
      fonts.sansSerif.name = "Test UI Font";
      opacity.desktop = 0.9;
      opacity.popups = 0.95;
      image = secondWallpaper;
      targets.celestia.colours.primary = "abcdef";
    };
    programs.caelestia.settings.appearance.font.body.medium.size = 19;
  };

  env = cfg: cfg.wayland.windowManager.hyprland.settings.env or [ ];
  findEnv = prefix: cfg: lib.findFirst (lib.hasPrefix "${prefix},") null (env cfg);
  schemeEnv = findEnv "CAELESTIA_STYLIX_SCHEME";
  wallpaperEnv = findEnv "CAELESTIA_STYLIX_WALLPAPER";
  schemePath = cfg: lib.removePrefix "CAELESTIA_STYLIX_SCHEME," (schemeEnv cfg);
  shellFile = cfg: cfg.xdg.configFile."caelestia/shell.json".source;
  noTheme =
    cfg:
    schemeEnv cfg == null && wallpaperEnv cfg == null && cfg.stylix.targets.celestia.colours == { };
  starts =
    program: cfg: lib.any (lib.hasInfix program) cfg.wayland.windowManager.hyprland.settings.exec-once;
in
assert
  config.programs.caelestia.enable && config.stylix.enable && config.stylix.targets.celestia.enable;
assert !config.programs.dank-material-shell.enable && !starts "dms run" config;
assert starts "caelestia-shell" config;
assert globalOff.programs.caelestia.enable && noTheme globalOff;
assert targetOff.programs.caelestia.enable && noTheme targetOff;
assert dms.stylix.enable && dms.programs.dank-material-shell.enable && noTheme dms;
assert starts "dms run" dms && !starts "caelestia-shell" dms;
assert wallpaperEnv config == null;
assert wallpaperEnv firstImage == "CAELESTIA_STYLIX_WALLPAPER,${firstWallpaper}";
assert !firstImage.services.hyprpaper.enable;
assert wallpaperEnv changed == "CAELESTIA_STYLIX_WALLPAPER,${secondWallpaper}";
assert schemePath changed != schemePath config;
pkgs.runCommand "znix-celestia-stylix-check"
  {
    nativeBuildInputs = [ pkgs.jq ];
  }
  ''
    # Every colour property consumed by the pinned shell is present in the output.
    sed -nE 's/^        property color (m3)?([[:alnum:]_]+):.*/\2/p'       ${inputs.caelestia-shell}/services/Colours.qml | sort > roles
    jq -r '.colours | keys[]' ${schemePath config} | sort > generated
    diff -u roles generated
    jq -e '
      .name == "stylix" and .mode == "dark"
      and .colours.primary == "${config.lib.stylix.colors.base0D}"
      and .colours.background == "${config.lib.stylix.colors.base00}"
      and .colours.error == "${config.lib.stylix.colors.base08}"
      and .colours.success == "${config.lib.stylix.colors.base0B}"
      and all(.colours[]; test("^[0-9a-fA-F]{6}$"))
    ' ${schemePath config}
    jq -e '
      .mode == "light" and .colours.primary == "abcdef"
      and .colours.background == "${changed.lib.stylix.colors.base00}"
      and .colours.background != "${config.lib.stylix.colors.base00}"
    ' ${schemePath changed}
    jq -e '
      .appearance.font.body.family == "${config.stylix.fonts.sansSerif.name}"
      and .appearance.font.mono.family == "${config.stylix.fonts.monospace.name}"
      and .appearance.transparency == {enabled: false, base: 1, layers: 1}
      and .services.smartScheme == false
    ' ${shellFile config}
    jq -e '
      .appearance.font.body.family == "Test UI Font"
      and .appearance.font.body.medium.size == 19
      and .appearance.font.label.family == "Test UI Font"
      and .appearance.transparency == {enabled: true, base: 0.9, layers: 0.95}
    ' ${shellFile changed}
    touch "$out"
  ''

{ pkgs, inputs }:
let
  home = inputs.self.homeConfigurations.zerokqx;
  config = home.config;
  withOverrides = overrides: (home.extendModules { modules = [ overrides ]; }).config;
  globalOff = withOverrides { stylix.enable = false; };
  targetOff = withOverrides { stylix.targets.ayugram.enable = false; };
  changed = withOverrides {
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-light-medium.yaml";
  };
  theme = cfg: cfg.home.file.".config/ayugram/stylix.tdesktop-theme".source;
  hasTheme = cfg: builtins.hasAttr ".config/ayugram/stylix.tdesktop-theme" cfg.home.file;
in
assert config.stylix.enable && config.stylix.targets.ayugram.enable && hasTheme config;
assert !hasTheme globalOff;
assert !hasTheme targetOff;
assert theme changed != theme config;
pkgs.runCommand "znix-ayugram-stylix-check" { nativeBuildInputs = [ pkgs.unzip ]; } ''
  unzip -p ${theme config} colors.tdesktop-theme > colors
  unzip -p ${theme changed} colors.tdesktop-theme > changed-colors
  grep -Fx 'dialogsBgActive: base02;' colors
  grep -Fx 'base00: #${config.lib.stylix.colors.base00};' colors
  grep -Fx 'base00: #${changed.lib.stylix.colors.base00};' changed-colors
  unzip -p ${theme config} tiled.png > wallpaper.png
  unzip -p ${theme changed} tiled.png > changed-wallpaper.png
  cmp wallpaper.png ${config.lib.stylix.pixel "base00"}
  cmp changed-wallpaper.png ${changed.lib.stylix.pixel "base00"}
  test "${config.lib.stylix.colors.base00}" != "${changed.lib.stylix.colors.base00}"
  touch "$out"
''

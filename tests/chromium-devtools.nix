{ pkgs, inputs }:
let
  home = inputs.self.homeConfigurations.zerokqx;
  config = home.config;
  withOverrides = overrides: (home.extendModules { modules = [ overrides ]; }).config;
  globalOff = withOverrides { stylix.enable = false; };
  targetOff = withOverrides { stylix.targets.chromium-devtools.enable = false; };
  frontendOff = withOverrides { programs.chromium.devtools.enable = false; };
  browserOff = withOverrides { programs.chromium.enable = pkgs.lib.mkForce false; };
  changed = withOverrides {
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-light-medium.yaml";
    stylix.polarity = "light";
    stylix.fonts.sansSerif.name = "DevTools Test Sans";
  };
  frontend = cfg: cfg.xdg.dataFile."chromium/devtools".source;
  hasFrontend = cfg: builtins.hasAttr "chromium/devtools" cfg.xdg.dataFile;
  hasFlag =
    cfg:
    builtins.any (pkgs.lib.hasPrefix "--custom-devtools-frontend=") cfg.programs.chromium.commandLineArgs;
in
assert hasFrontend config && hasFlag config;
assert !hasFrontend frontendOff && !hasFlag frontendOff;
assert !hasFrontend browserOff && !hasFlag browserOff;
assert frontend globalOff == frontend targetOff;
assert frontend targetOff != frontend config;
assert frontend changed != frontend config;
pkgs.runCommand "znix-chromium-devtools-check" { nativeBuildInputs = [ pkgs.nodejs ]; } ''
  test -f ${frontend config}/devtools_app.html
  test -f ${frontend config}/panels/elements/elements.js
  test -f ${frontend config}/panels/sources/sources.js
  test -f ${frontend config}/panels/timeline/timeline.js
  test -f ${frontend config}/LICENSE.chromium-devtools
  test -f ${frontend config}/lucide-license.txt
  grep -F -- '--znix-base00: #${config.lib.stylix.colors.base00};' ${frontend config}/design_system_tokens.css
  grep -F -- '--znix-base00: #${changed.lib.stylix.colors.base00};' ${frontend changed}/design_system_tokens.css
  grep -F -- '--znix-font-sans: "DevTools Test Sans", sans-serif;' ${frontend changed}/design_system_tokens.css
  grep -F -- 'color-scheme: light;' ${frontend changed}/design_system_tokens.css
  if grep -q -- '--znix-base00:' ${frontend targetOff}/design_system_tokens.css; then
    echo 'Stylix declarations leaked into the disabled target' >&2
    exit 1
  fi
  grep -q -- '--znix-tab-height: 48px;' ${frontend config}/design_system_tokens.css
  grep -q -- '--znix-field-height: 56px;' ${frontend targetOff}/design_system_tokens.css
  cmp ${../home/zerokqx/chromium/frontend/icons/settings-2.svg} ${frontend config}/Images/gear.svg
  grep -q 'environment-meta.js' ${frontend config}/entrypoints/devtools_app/devtools_app.js
  grep -q 'installZnixStorageEditor(this)' ${frontend config}/panels/application/application.js
  for bundle in ui/legacy/legacy.js ui/components/buttons/buttons.js panels/console/console.js panels/network/network.js panels/application/application.js entrypoints/devtools_app/devtools_app.js; do
    node --input-type=module --check < ${frontend config}/"$bundle"
  done
  for module in ${frontend config}/znix/*.js; do
    node --input-type=module --check < "$module"
  done
  node ${./chromium-storage-editor.mjs} ${../home/zerokqx/chromium/frontend/storage-editor.js}
  node ${./chromium-environment.mjs} ${../home/zerokqx/chromium/frontend/environment-overrides.js}
  touch "$out"
''

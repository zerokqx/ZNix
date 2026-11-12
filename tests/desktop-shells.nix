{ pkgs, homeConfigurations }:
let
  inherit (pkgs.lib)
    any
    assertMsg
    count
    hasInfix
    ;
  home = homeConfigurations.zerokqx;
  caelestia = home.config;
  dms =
    (home.extendModules {
      modules = [ { programs.caelestia.enable = false; } ];
    }).config;
  both = (
    home.extendModules {
      modules = [ { programs.dank-material-shell.enable = true; } ];
    }
  );

  startup = cfg: cfg.wayland.windowManager.hyprland.settings.exec-once;
  bindings =
    cfg:
    let
      settings = cfg.wayland.windowManager.hyprland.settings;
    in
    settings.bind ++ settings.bindel ++ settings.bindl;
  hasCommand = command: any (hasInfix command);
  shellServicesAbsent =
    cfg:
    let
      services = cfg.systemd.user.services;
    in
    !(services ? caelestia || services ? dms || services ? hyprpolkitagent);
in
assert assertMsg (
  caelestia.programs.caelestia.enable
  && !caelestia.programs.dank-material-shell.enable
  && count (hasInfix "/bin/caelestia-shell ") (startup caelestia) == 1
  && count (hasInfix "/libexec/hyprpolkitagent") (startup caelestia) == 1
  && count (hasInfix "/bin/cliphist store") (startup caelestia) == 1
  && !hasCommand "dms run" (startup caelestia)
  && !hasCommand "dms " (bindings caelestia)
  && caelestia.xdg.configFile ? "caelestia/shell.json"
  && !(caelestia.xdg.configFile ? "DankMaterialShell/settings.json")
  && shellServicesAbsent caelestia
) "Caelestia must start once, with its own controls, clipboard history and polkit agent.";
assert assertMsg (
  !dms.programs.caelestia.enable
  && dms.programs.dank-material-shell.enable
  && count (command: command == "dms run") (startup dms) == 1
  && !hasCommand "/bin/caelestia-shell" (startup dms)
  && !hasCommand "/libexec/hyprpolkitagent" (startup dms)
  && !hasCommand "/bin/cliphist store" (startup dms)
  && !hasCommand "caelestia" (bindings dms)
  && hasCommand "dms ipc call launcher toggle" (bindings dms)
  && dms.xdg.configFile ? "DankMaterialShell/settings.json"
  && !(dms.xdg.configFile ? "caelestia/shell.json")
  && shellServicesAbsent dms
) "The DMS fallback must restore DMS controls and keep Caelestia out of the session.";
assert assertMsg (
  !(builtins.tryEval both.config.home.username).success
) "Simultaneous desktop shells must fail Home Manager evaluation.";
pkgs.runCommand "znix-desktop-shells" { } ''
  touch "$out"
''

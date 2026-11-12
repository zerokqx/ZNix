{ pkgs, homeConfigurations }:
let
  inherit (pkgs.lib)
    any
    assertMsg
    count
    getExe
    getExe'
    hasInfix
    removePrefix
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
  hasClipboardBindings =
    command: cfg:
    builtins.elem "$mod, v, exec, ${command}" (bindings cfg)
    && builtins.elem "$mod SHIFT, v, exec, ${command}" (bindings cfg);
  logoutBindingPrefix = "$mod SHIFT, e, exec, ";
  logout = removePrefix logoutBindingPrefix (
    pkgs.lib.findFirst (pkgs.lib.hasPrefix logoutBindingPrefix) "" (bindings caelestia)
  );
  hasLogoutBindings =
    cfg:
    builtins.elem "${logoutBindingPrefix}${logout}" (bindings cfg)
    && builtins.elem "CTRL ALT, Delete, exec, ${logout}" (bindings cfg);
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
  && hasClipboardBindings "${getExe caelestia.programs.caelestia.package} ipc call drawers toggle clipboard" caelestia
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
  && hasClipboardBindings "dms ipc call clipboard toggle" dms
  && dms.xdg.configFile ? "DankMaterialShell/settings.json"
  && !(dms.xdg.configFile ? "caelestia/shell.json")
  && shellServicesAbsent dms
) "The DMS fallback must restore DMS controls and keep Caelestia out of the session.";
assert assertMsg (
  !(builtins.tryEval both.config.home.username).success
) "Simultaneous desktop shells must fail Home Manager evaluation.";
assert assertMsg (
  logout != "" && hasLogoutBindings caelestia && hasLogoutBindings dms
) "Both desktop shells must use the same session logout command for both exit shortcuts.";
pkgs.runCommand "znix-desktop-shells" { nativeBuildInputs = [ pkgs.jq ]; } ''
  test -x ${logout}
  jq -e --arg logout ${logout} '
    .session.commands.logout == [$logout]
    and .utilities.toasts == {kbLayoutChanged: false}
    and ([.bar.statusIcons[] | select(.enabled) | .id] == [
      "lockStatus", "kbLayout", "network", "bluetooth", "battery"
    ])
  ' ${caelestia.xdg.configFile."caelestia/shell.json".source}

  # Run the generated body with only the stubs and grep on PATH.
  mkdir stubs
  tail -n +2 ${logout} > logout-body
  substitute logout-body logout-stub \
    --replace-fail '${getExe' pkgs.systemd "systemctl"}' systemctl \
    --replace-fail '${getExe pkgs.uwsm}' uwsm \
    --replace-fail '${getExe' caelestia.wayland.windowManager.hyprland.package "hyprctl"}' hyprctl \
    --replace-fail '${getExe pkgs.gnugrep}' grep
  if grep -Fq /nix/store/ logout-stub; then
    echo 'Unexpected absolute store path in logout script' >&2
    exit 1
  fi

  cat > stubs/systemctl <<'EOF'
  #!${pkgs.runtimeShell}
  case "$*" in
    '--user --quiet is-active wayland-wm@*.service') exit "$ACTIVE_STATUS" ;;
    '--user show-environment')
      [ "$SHOW_STATUS" = 0 ] || exit "$SHOW_STATUS"
      printf 'HYPRLAND_INSTANCE_SIGNATURE=%s\n' "$MANAGER_SIGNATURE"
      ;;
    *) exit 125 ;;
  esac
  EOF
  cat > stubs/uwsm <<'EOF'
  #!${pkgs.runtimeShell}
  printf 'uwsm %s\n' "$*"
  exit "$UWSM_STATUS"
  EOF
  cat > stubs/hyprctl <<'EOF'
  #!${pkgs.runtimeShell}
  printf 'hyprctl %s\n' "$*"
  EOF
  chmod +x stubs/{systemctl,uwsm,hyprctl}
  ln -s ${getExe pkgs.gnugrep} stubs/grep

  check_logout() {
    local name=$1 expected_status=$2 expected_command=$3 output status=0
    shift 3
    output=$(env -i PATH="$PWD/stubs" HYPRLAND_INSTANCE_SIGNATURE=current MANAGER_SIGNATURE=current \
      ACTIVE_STATUS=0 SHOW_STATUS=0 UWSM_STATUS=0 "$@" ${pkgs.runtimeShell} logout-stub) || status=$?
    if [[ "$status" != "$expected_status" || "$output" != "$expected_command" ]]; then
      printf '%s: exit status %s, command %s\n' "$name" "$status" "$output" >&2
      exit 1
    fi
  }

  check_logout managed 0 'uwsm stop'
  check_logout failed-uwsm 1 'uwsm stop' UWSM_STATUS=1
  check_logout inactive-uwsm 0 'hyprctl dispatch exit' ACTIVE_STATUS=3
  check_logout absent-uwsm 0 'hyprctl dispatch exit' ACTIVE_STATUS=4
  check_logout other-instance 0 'hyprctl dispatch exit' MANAGER_SIGNATURE=other
  check_logout missing-signature 1 "" HYPRLAND_INSTANCE_SIGNATURE=
  check_logout failed-status 1 "" ACTIVE_STATUS=1
  check_logout failed-environment 1 "" SHOW_STATUS=1
  touch "$out"
''

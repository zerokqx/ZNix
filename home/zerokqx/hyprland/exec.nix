{
  config,
  lib,
  pkgs,
  ...
}:
{
  wayland.windowManager.hyprland.settings.exec-once = [
    "mullvad-vpn"
    "[workspace special:ayugram silent] AyuGram"
  ]
  ++ lib.optionals config.programs.caelestia.enable [
    "${lib.getExe config.programs.caelestia.package} -n"
    "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
    "${pkgs.wl-clipboard}/bin/wl-paste --watch ${lib.getExe pkgs.cliphist} store"
  ]
  ++ lib.optional config.programs.dank-material-shell.enable "dms run";
}

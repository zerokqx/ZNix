{
  services.flatpak.overrides.global.Context.sockets = [
    "wayland"
    "session-bus"
    "system-bus"
    "!x11"
    "!fallback-x11"
  ];
  services.flatpak.packages = [
  ];
}

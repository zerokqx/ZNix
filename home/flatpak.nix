{
  services.flatpak.overrides.global.Context.sockets = [
    "wayland"
    "!x11"
    "!fallback-x11"
  ];
  services.flatpak.packages = [
    "io.github.purplehorrorrus.Meridius"
  ];
}

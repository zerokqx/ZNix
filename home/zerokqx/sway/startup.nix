{
  wayland.windowManager.sway.config.startup = [
    { command = "exec dbus-update-activation-environment --systemd SSH_AUTH_SOCK WAYLAND_DISPLAY DISPLAY"; }
    { command = "exec wl-paste --watch cliphist store"; }
    { command = "exec Throne"; }
    { command = "exec AyuGram"; }
    { command = "exec dms run"; }
    { command = "exec autotiling-rs"; }
  ];
}

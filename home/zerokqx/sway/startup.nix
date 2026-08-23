{

  wayland.windowManager.sway.config.startup = [
    { command = "exec dbus-update-activation-environment --systemd SSH_AUTH_SOCK"; }
    { command = "exec wl-paste --watch cliphist store"; }
    { command = "exec Throne"; }
    { command = "exec AyuGram"; }
    { command = "exec noctalia-shell"; }
    { command = "exec autotiling-rs"; }
  ];
}

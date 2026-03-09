{

  wayland.windowManager.sway.config.startup = [
    { command = "exec wl-paste --watch cliphist store"; }
    { command = "exec Throne"; }
    { command = "exec AyuGram"; }
    { command = "exec noctalia-shell"; }
    { command = "exec autotiling-rs"; }
  ];
}

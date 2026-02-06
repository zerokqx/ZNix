{

  wayland.windowManager.sway.config.startup = [
    { command = "exec wl-paste --watch cliphist store"; }
    { command = "exec Throne"; }
    { command = "exec firefox-nightly"; }
    { command = "exec AyuGram"; }
    { command = "exec flatpak run io.github.purplehorrorrus.Meridius"; }
    { command = "exec noctalia-shell"; }
    { command = "exec autotiling-rs"; }
  ];
}

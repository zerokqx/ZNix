{

  wayland.windowManager.sway.config.startup = [
    { command = "exec wl-paste --watch cliphist store"; }
    { command = "exec Throne"; }

    { command = "exec $BROWSER"; }
    { command = "exec spotify"; }
    { command = "exec AyuGram"; }
    { command = "exec exec_once $BROWSER"; }
    { command = "exec noctalia-shell"; }
    { command = "exec autotiling-rs"; }

  ];
}

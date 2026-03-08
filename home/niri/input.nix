{
  programs.niri.settings = {
    input.keyboard.xkb = {
      layout = "us,ru";
      options = "caps:escape";
    };
    input.keyboard.numlock = true;
    input.focus-follows-mouse = {
      enable = true;
      max-scroll-amount = "0%";
    };
    input.touchpad = {
      tap = true;
      dwt = true;
      dwtp = true;
      drag = true;
      drag-lock = true;
      scroll-method = "two-finger";
      disabled-on-external-mouse = true;
    };
  };
}

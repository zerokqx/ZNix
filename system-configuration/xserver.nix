{ ... }: {

  services.xserver = {
    videoDrivers = [ "amdgpu" "radeon" ];
    enable = true;
    xkb = {
      layout = "us,ru";
      options = "grp:win_space_toggle,caps:escape";
    };
  };
}

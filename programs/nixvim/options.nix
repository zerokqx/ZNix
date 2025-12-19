{ lib, pkgs, ... }:
with lib;
{

  options.animations = mkOption {

    type = types.bool;
    default = true;
    description = "Set animation smear cursor and scroll";
  };
}

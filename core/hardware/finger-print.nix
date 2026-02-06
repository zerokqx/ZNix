{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.hardware.fingerprint.goodix;
in
{
  options.hardware.fingerprint.goodix = {
    enable = lib.mkEnableOption "Enable Goodix fingerprint (fprintd + TOD driver)";
  };

  config = lib.mkIf cfg.enable {
    services.fprintd.enable = true;
    services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;
  };
}

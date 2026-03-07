{ lib, config, ... }:
{
  options.znix.vm.waydroid.enable = lib.mkEnableOption "Enable waydroid";

  config = lib.mkIf config.znix.vm.waydroid.enable {
    virtualisation.waydroid.enable = true;
    networking.firewall = {
      allowedTCPPorts = [
        53
        67
      ];
      trustedInterfaces = [ "waydroid0" ];
    };
  };

}

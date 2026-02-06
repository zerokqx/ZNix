{ lib, config, ... }:
let
  cfg = config.dev.ports;
in
{
  options.dev.ports = {
    enable = lib.mkEnableOption "Enable default dev ports";

    interface = lib.mkOption {
      type = lib.types.str;
      default = "wlp0s20f0u2";
      description = "Network interface name (see `ip a`).";
    };

    tcpPorts = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [
        3000
        5173
        8000
      ];
      description = "Dev TCP ports to allow on LAN interface.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = {
      enable = true;
      interfaces.${cfg.interface}.allowedTCPPorts = cfg.tcpPorts;
    };
  };
}

{ ... }: {
  hardware.enableRedistributableFirmware = true;
  imports = [ ./bluetooth.nix ./graphics.nix ];
}

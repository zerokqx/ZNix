{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nftables
    interception-tools
    exfat
    usbutils
    wget
  ];

  environment.shells = with pkgs; [ fish ];
}

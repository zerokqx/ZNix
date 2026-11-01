{ pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    nftables
    interception-tools
    nix-ld
    exfat
    usbutils
    wget
    polkit_gnome
    xdg-utils
  ];

  environment.shells = with pkgs; [ fish ];
}

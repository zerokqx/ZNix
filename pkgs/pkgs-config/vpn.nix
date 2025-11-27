{ pkgs, ... }:
{
  services.v2raya.enable = true;
  environment.systemPackages = with pkgs; [
    pkgs.xray
    pkgs.sing-box
    pkgs.v2rayn
  ];

}

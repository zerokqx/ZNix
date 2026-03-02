{ pkgs, ... }:
{
  plugins.roslyn.enable = true;
  plugins.rzls.enable = true;
  extraPackages = with pkgs; [
    dotnetCorePackages.sdk_9_0-bin
  ];

}

{ pkgs, ... }:
{
  plugins.roslyn.enable = false;
  plugins.rzls.enable = false;
  # extraPackages = with pkgs; [
  #   dotnetCorePackages.sdk_9_0-bin
  # ];

}

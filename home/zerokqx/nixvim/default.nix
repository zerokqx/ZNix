{ ... }:
{
  programs.nixvim = {
    enable = true;
    wrapRc = true;
    imports = [ ./config.nix ];
  };
}

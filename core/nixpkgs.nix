{ ... }:
{

  nix.settings.trusted-users = [
    "root"
    "zerok"
  ];
  nixpkgs.config.allowUnfree = true;

}

{ inputs, ... }:
{
  imports = [
    ../core/users
    ../configs
  ];

  home-manager.users.zerok.imports = (import ../lib/home-modules.nix inputs) ++ [ ../home/zerokqx ];
}

{ inputs, ... }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    ../../configuration.nix
    ./hardware-configuration.nix
    {
      home-manager.users.zerok = {
        imports = [
          ../../home/noop
        ];
        programs.dank-material-shell.enable = true;
      };
    }
  ];
}

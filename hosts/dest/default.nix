{ inputs, ... }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    ../../configuration.nix
    ./hardware-configuration.nix
    {
      home-manager.users.zerok = {
        znix.browser.enable = true;
      };
    }
  ];
}

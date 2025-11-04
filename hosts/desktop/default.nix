{ inputs, ... }:
let gAttr = import ../general-attr.nix;
in inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    inputs.home-manager.nixosModules.home-manager
    { home-manager.users.zerok.imports = [ ../../home-manager ]; }
    gAttr.home-manager-settings

    {
      services.syncthing = {
        settings = {

          folders."Obsidian".devices = [ "samsung" ];
          devices = {

            "samsung" = {
              id =
                "NC2PQPF-VHC7PKH-CLYO3R5-A6AK6HN-RDIFQF5-GUD76E2-PMC6WFK-LIYV5AR";
            };
          };
        };
      };

    }
    ./hardware-configuration.nix
    ./pkgs.nix
  ] ++ gAttr.general-path;
}

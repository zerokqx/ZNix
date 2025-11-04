{ inputs, ... }:
let
  gAttr = import ../general-attr.nix;
  certs = import ../../utils/getCerts.nix {
    service = "syncthing";
    host = "laptop";
  };
in inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.users.zerok.imports =
        [ ../../home-manager ./output-sway-rewrite.nix ];
    }
    {
      services.syncthing = {
        inherit (certs) cert key;
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
    gAttr.home-manager-settings
    ./hardware-configuration.nix
    ./postgres.nix
  ] ++ gAttr.general-path;
}

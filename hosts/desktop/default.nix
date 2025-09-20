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
      services.syncthing.settings.devices = {
        "samsung" = { id = "id"; };
        "notebook" = {
          id =
            "CEK5F3K-DKBUKFM-Q7DA5LI-LHRXVS7-CWHW2PY-XYBQZRQ-GIEZUNF-5WN4BAX";
        };
      };

    }
    ./hardware-configuration.nix
  ] ++ gAttr.general-path;
}

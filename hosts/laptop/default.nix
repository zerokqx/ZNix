{ inputs, ... }:
let gAttr = import ../general-attr.nix;
in inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.users.zerok.imports =
        [ ../../home-manager ./output-sway-rewrite.nix ];
    }
    { services.syncthing.settings.devices = { "desktop" = { id = "id"; }; }; }
    gAttr.home-manager-settings
    ./hardware-configuration.nix
  ] ++ gAttr.general-path;
}

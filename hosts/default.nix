{ inputs, ... }:
let
  nixosSystem = inputs.nixpkgs.lib.nixosSystem;
  home-manager = inputs.home-manager.nixosModules.home-manager;
  home-manager-settings = {

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "backup";
    home-manager.users.zerok = { imports = [ ../home-manager ]; };

  };
  general-path = [

    ../configuration.nix
    ../pkgs
    ../system-configuration
    ../hardware
  ];
  hardware = name: ./hardware/${name}-hardware-configuration.nix;
in {
  flake.nixosConfigurations = {

    desktop = nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [ home-manager home-manager-settings (hardware "desktop") ]
        ++ general-path;
    };
    laptop = nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [ home-manager home-manager-settings (hardware "laptop") ]
        ++ general-path;
    };
  };
}

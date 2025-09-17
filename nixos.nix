{ inputs, ... }: {
  flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./pkgs.nix
      ./configuration.nix
      ./pkgs-config
      ./system-configuration
      ./hardware
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.users.zerok = { imports = [ ./home-manager ]; };
      }
    ];
  };
}

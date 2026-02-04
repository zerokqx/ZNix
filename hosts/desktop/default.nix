{ inputs, ... }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    ../../configuration.nix
    ../../configuration.nix
    ./hardware-configuration.nix
    ./ollama.nix
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.users.zerok.imports = [
        ./opencode.nix
        inputs.nix-flatpak.homeManagerModules.nix-flatpak
        inputs.stylix.homeModules.stylix
        inputs.noctalia.homeModules.default
        inputs.nixvim.homeModules.nixvim
        ../../home
      ];
    }
  ];
}

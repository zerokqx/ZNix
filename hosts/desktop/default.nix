{ inputs, ... }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    ./hardware-configuration.nix
    ../../configuration.nix
    ./ollama.nix
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.users.zerok.imports = [
        ../../home
        ./opencode.nix
        inputs.stylix.homeModules.stylix
        inputs.noctalia.homeModules.default
        inputs.spicetify-nix.homeManagerModules.default
        inputs.nixvim.homeModules.nixvim
      ];
    }
  ];
}

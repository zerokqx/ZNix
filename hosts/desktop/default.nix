{ inputs, ... }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [

    ../../configuration.nix
    ../../configuration.nix
    ./hardware-configuration.nix
    ./ollama.nix
    {

      ai.sillytavern.enable = true;
    }
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.backupFileExtension = "hm-bak";
      home-manager.users.zerok.imports = [
        ./opencode.nix
        (
          { ... }:
          {
            programs.noctalia-shell.settings.bar.position = "bottom";
          }
        )
        {

        }
        inputs.nix-flatpak.homeManagerModules.nix-flatpak
        inputs.stylix.homeModules.stylix
        inputs.noctalia.homeModules.default
        inputs.nixvim.homeModules.nixvim
        ../../home
      ];
    }
  ];
}

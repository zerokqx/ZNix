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

      znix.ai.sillytavern.enable = true;
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
            znix.monitors = {
              noctaliaMonitors = [ "DP-1" ];
              list = {
                "DP-1" = {
                  mode = "1920x1080@165Hz";
                  pos = "0 0";
                };
                "HDMI-A-1" = {
                  mode = "1920x1080@75Hz";
                  pos = "1920 0";
                };
              };
            };
          }
        )
        (
          { ... }:
          {
            znix.browser.enable = true;
            programs.noctalia-shell.settings.bar.position = "bottom";
          }
        )
        inputs.stylix.homeModules.stylix
        inputs.noctalia.homeModules.default
        inputs.nixvim.homeModules.nixvim
        ../../home
      ];
    }
  ];
}

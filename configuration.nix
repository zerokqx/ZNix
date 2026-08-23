{
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
    inputs.home-manager.nixosModules.home-manager
    ./core
    ./configs
  ];

  # Общая интеграция Home-Manager для пользователя zerok
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "hm-bak";
    users.zerok.imports = [
      inputs.stylix.homeModules.stylix
      inputs.dms.homeModules.dank-material-shell
      inputs.dms-plugin-registry.homeModules.default
      inputs.noctalia.homeModules.default
      inputs.nixvim.homeModules.nixvim
      ./home/zerokqx
    ];
  };
  programs = {
    hyprland.enable = true;
    hyprland.withUWSM = false;
    command-not-found.enable = false;
    gnupg.agent.enable = true;
    nix-ld.enable = true;
    # light.enable = true;
    fish.enable = true;
    direnv.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession = {
        enable = true;
        args = [
          "-O"
          "DP-1"
        ];
      };
    };
    gamescope = {
      enable = true;
    };
    ssh.startAgent = lib.mkForce true;
    localsend.enable = true;
  };

  system.stateVersion = "26.05";
}

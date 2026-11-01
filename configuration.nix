{
  lib,
  inputs,
  pkgs,
  ...
}:
{
  nixpkgs.overlays = [ inputs.nix-claude-code.overlays.default ];

  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
    inputs.home-manager.nixosModules.home-manager
    ./core
    ./configs
  ];
  znix.dev.ports.enable = true;
  nix.settings = {
    substituters = [
      "https://cachix.org"
      "https://ryoppippi.cachix.org"
    ];
    trusted-public-keys = [
      "codex-cli.cachix.org-1:99/pSg8Gg8jBw1XvW8Dny3BfV6Z7K7c8Wb6Z7K7c8Wb="
      "ryoppippi.cachix.org-1:b2LbtWNvJeL/qb1B6TYOMK+apaCps4SCbzlPRfSQIms="
    ];
  };
  services.input-remapper.enable = true;
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "hm-bak";
    users.zerok.imports = [
      inputs.stylix.homeModules.stylix
      inputs.dms.homeModules.dank-material-shell
      inputs.dms-plugin-registry.homeModules.default
      inputs.nixvim.homeModules.nixvim
      ./home/zerokqx
    ];
  };
  programs = {
    hyprland.enable = true;
    hyprland.withUWSM = true;
    command-not-found.enable = false;
    gnupg.agent.enable = true;
    nix-ld.enable = true;

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
    gamemode.enable = true;
  };

  system.stateVersion = "26.05";
}

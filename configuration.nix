{
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./core
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "hm-bak";
  };

  programs = {
    command-not-found.enable = false;
    gnupg.agent.enable = true;
    fish.enable = true;
    ssh.startAgent = lib.mkForce true;
  };

  system.stateVersion = "26.05";
}

{
  home-manager-settings = {
    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;
      backupFileExtension = "backup";
    };
  };

  general-path = [

    ../configuration.nix
    ../pkgs
    ../system-configuration
    ../hardware
  ];
}

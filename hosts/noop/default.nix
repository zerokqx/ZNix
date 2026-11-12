{
  imports = [
    ../../configuration.nix
    ../../profiles/workstation.nix
    ../../profiles/development.nix
    ../../profiles/personal.nix
    ./hardware-configuration.nix
    # Keep this definition after personal.nix at the same module depth.
    # Home Manager merges ordered lists from both profiles.
    {
      home-manager.users.zerok = {
        imports = [ ../../home/noop ];
        programs.dank-material-shell.enable = true;
      };
    }
  ];
}

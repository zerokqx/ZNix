{
  imports = [
    ../core/docker.nix
    ../core/nix-ld.nix
  ];

  znix.dev.ports.enable = true;
  programs.direnv.enable = true;
}

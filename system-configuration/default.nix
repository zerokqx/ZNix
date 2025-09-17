{ ... }: {
  imports = [
    ./boot.nix
    ./users
    ./timezone.nix
    ./xserver.nix
    ./networking.nix
    ./nixpkgs.nix
  ];
}

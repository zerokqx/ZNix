{ pkgs, ... }: {
  imports = [
    ./nixosvmtest.nix
    ./zerok.nix

  ];

  users.defaultUserShell = pkgs.fish;
}

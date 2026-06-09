{
  imports = [
    ./package.nix
    ./base.nix
    ./monitors.nix
    ./animations.nix
    ./binds.nix
    ./exec.nix
    ./input.nix
    ./general.nix
    ./rules.nix
  ];
  services.hyprpolkitagent.enable = true;
}

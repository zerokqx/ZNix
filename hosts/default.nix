{ inputs, ... }:
let
  system = "x86_64-linux";
  pkgs = inputs.nixpkgs.legacyPackages.${system};

  args = { inherit inputs pkgs system; };

  desktop = import ./desktop args;
  laptop = import ./laptop args;
in
{
  flake.nixosConfigurations = { inherit desktop laptop; };
}

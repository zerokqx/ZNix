{ inputs, pkgs, ... }:
let
  desktop = import ./desktop { inherit inputs; };
  laptop = import ./laptop { inherit inputs; };
in
{
  flake.nixosConfigurations = {

    inherit desktop;
    inherit laptop;
  };
}

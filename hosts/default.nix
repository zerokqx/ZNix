{ inputs, lib, ... }@args:
let

  desktop = import ./desktop args;
  laptop = import ./laptop args;
in
{
  flake.nixosConfigurations = { inherit desktop laptop; };
}

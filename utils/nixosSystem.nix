{ inputs, ... }:
let

  nixosSystem = inputs.nixpkgs.lib.nixosSystem;

in nixosSystem

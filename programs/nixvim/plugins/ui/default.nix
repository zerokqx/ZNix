{ lib, ... }:

let
  importFilesDir = import ../../utils/importFilesDir.nix { inherit lib; };
in
{

  imports = [
  ]
  ++ importFilesDir ./.;
}

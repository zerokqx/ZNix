{ lib }:
dir:
let
  files = builtins.readDir dir;
  nixFiles = builtins.attrNames (
    lib.filterAttrs (
      name: type:
      type == "regular"
      && builtins.match ".*\\.nix$" name != null
      && name != "default.nix"
      && !(builtins.match ".*\\.off\\.nix$" name != null) # Исключаем .off.nix
    ) files

  );
in
map (file: "${dir}/${file}") nixFiles

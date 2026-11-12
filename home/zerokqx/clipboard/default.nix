{ lib, pkgs }:
let
  python = pkgs.python3.withPackages (ps: [ ps.pillow ]);
in
pkgs.writeShellApplication {
  name = "znix-clipboard-backend";
  runtimeInputs = [
    pkgs.cliphist
    pkgs.wl-clipboard
  ];
  text = ''
    exec ${lib.getExe python} ${./history.py} "$@"
  '';
}

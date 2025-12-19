{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "rofishot";
  version = "1.0";
  src = ./.;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  buildInputs = [
    pkgs.grim
    pkgs.slurp
    pkgs.wl-clipboard
    pkgs.rofi
    pkgs.libnotify

    pkgs.wf-recorder
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp rofishot.bash $out/bin/rofishot
    chmod +x $out/bin/rofishot

    wrapProgram $out/bin/rofishot \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.grim
          pkgs.slurp
          pkgs.wl-clipboard
          pkgs.rofi
          pkgs.libnotify
          pkgs.wf-recorder
        ]
      }
  '';
}

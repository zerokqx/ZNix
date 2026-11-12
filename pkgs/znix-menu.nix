{ lib, rustPlatform }:
let
  source = ../rust/znix-menu;
in
rustPlatform.buildRustPackage {
  pname = "znix-menu";
  version = "0.1.0";
  src = lib.fileset.toSource {
    root = source;
    fileset = lib.fileset.unions [
      (source + /Cargo.lock)
      (source + /Cargo.toml)
      (source + /config.json)
      (source + /src)
    ];
  };
  cargoLock.lockFile = source + /Cargo.lock;
}

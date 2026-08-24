{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{

  env.GREET = "devenv";

  packages = [
    pkgs.rustup
    pkgs.git
  ];

  scripts.menu.exec = "cargo run";

  languages.rust = {
    enable = true;
    channel = "stable";
  };

}

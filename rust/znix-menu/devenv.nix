{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
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

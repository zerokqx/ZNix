{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  env.GREET = "Zerokqx config NixOs";

  packages = [
    pkgs.git
    pkgs.bun
    pkgs.gum
  ];

  scripts.nixvimRun.exec = ''
    nix run ./programs/nixvim/
  '';
  # scripts.buildSystem = ''
  #   sudo
  # '';
  scripts.rebuild.exec = ''
    git add .
    bun ./hostChoice/
  '';
  enterShell = ''
       bun i
    bun ./hostChoice/welcome.js
  '';

  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

}

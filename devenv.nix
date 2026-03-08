{
  pkgs,
  ...
}:

{
  env.GREET = "Zerokqx config NixOs";

  packages = [
    pkgs.git
  ];

  scripts.backup.exec = ''
      mkdir -p ~/backups/ZNix
      tar -czf ~/backups/ZNix/backup-$(date +%F).tar.gz \
      --exclude=./node_modules \
        .
  '';
  scripts.rebuild-desktop.exec = "git add . && sudo nixos-rebuild switch --flake .#desktop --show-trace";
  scripts.rebuild-laptop.exec = "git add . && sudo nixos-rebuild switch --flake .#laptop --show-trace";
  scripts.rebuild-desktop-test.exec = "git add . && sudo nixos-rebuild test --flake .#desktop --show-trace";
  scripts.rebuild-laptop-test.exec = "git add . && sudo nixos-rebuild test --flake .#laptop --show-trace";
  scripts.rebuild-desktop-vm.exec = ''
    git add .
    sudo nixos-rebuild build-vm --flake .#desktop --show-trace
    ./result/bin/run-nixos-vm
  '';
  scripts.flake-check.exec = "nix flake check --show-trace";
  enterTest = ''
    echo $GREET
  '';

  enterShell = ''
    printf "                        \033[1;38;5;27m███████╗███╗   ██╗██╗██╗  ██╗\033[0m\n"
    printf "                        \033[1;38;5;33m╚══███╔╝████╗  ██║██║╚██╗██╔╝\033[0m\n"
    printf "                        \033[1;38;5;39m  ███╔╝ ██╔██╗ ██║██║ ╚███╔╝ \033[0m\n"
    printf "                        \033[1;38;5;45m ███╔╝  ██║╚██╗██║██║ ██╔██╗ \033[0m\n"
    printf "                        \033[1;38;5;51m███████╗██║ ╚████║██║██╔╝ ██╗\033[0m\n"
    printf "                        \033[1;38;5;123m╚══════╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝\033[0m\n"
    ./scripts/parse-flake.sh .
  '';

}

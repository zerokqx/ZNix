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
  enterTest = ''
    echo $GREET
  '';

}

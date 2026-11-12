{
  pkgs,
  ...
}:

{
  env.GREET = "Zerokqx config NixOs";

  packages = [
    pkgs.git
    pkgs.nixfmt
    pkgs.python3
    pkgs.shellcheck
  ];

  scripts.backup.exec = ''
    mkdir -p ~/backups/ZNix
    tar -czf ~/backups/ZNix/backup-$(date +%F).tar.gz \
    --exclude=./node_modules \
      .
  '';
  scripts.rebuild-desktop.exec = ''exec "$DEVENV_ROOT/scripts/rebuild.sh" switch desktop'';
  scripts.rebuild-laptop.exec = ''exec "$DEVENV_ROOT/scripts/rebuild.sh" switch laptop'';
  scripts.rebuild-noop.exec = ''exec "$DEVENV_ROOT/scripts/rebuild.sh" switch noop'';
  scripts.rebuild.exec = ''exec "$DEVENV_ROOT/scripts/rebuild.sh" "$@"'';
  scripts.theme-link-git.exec = "chromium https://github.com/tinted-theming/base16-schemes";
  scripts.theme-link-galery.exec = "chromium https://dt.iki.fi/base16-previews";
  scripts.rebuild-desktop-test.exec = ''exec "$DEVENV_ROOT/scripts/rebuild.sh" test desktop'';
  scripts.rebuild-laptop-test.exec = ''exec "$DEVENV_ROOT/scripts/rebuild.sh" test laptop'';
  scripts.rebuild-noop-test.exec = ''exec "$DEVENV_ROOT/scripts/rebuild.sh" test noop'';
  scripts.rebuild-desktop-vm.exec = ''exec "$DEVENV_ROOT/scripts/rebuild.sh" vm desktop'';
  scripts.flake-check.exec = ''
    exec nix develop --no-update-lock-file "$DEVENV_ROOT" \
      --command "$DEVENV_ROOT/scripts/check.sh" "$@"
  '';
}

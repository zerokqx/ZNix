{ lib, pkgs, ... }:
{
  # Codex updates its local settings. Restore missing files as writable copies.
  home.activation.restoreCodexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    (
      umask 077
      run ${pkgs.coreutils}/bin/mkdir -p "$HOME/.codex" "$HOME/.agents/skills"
      run ${pkgs.coreutils}/bin/cp -R --update=none --no-preserve=mode \
        ${./.}/{AGENTS.md,config.toml,agents,rules,skills} "$HOME/.codex/"
      run ${pkgs.coreutils}/bin/cp -R --update=none --no-preserve=mode \
        ${./agent-skills}/. "$HOME/.agents/skills/"
    )
  '';
}

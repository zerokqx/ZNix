{
  config,
  lib,
  pkgs,
  ...
}:
let
  colors = config.lib.stylix.colors.withHashtag;
  theme = {
    accent = colors.base0D;
    accentSource = "custom";
    contrast = 60;
    ink = colors.base05;
    opaqueWindows = true;
    surface = colors.base00;
    fonts = {
      code = config.stylix.fonts.monospace.name;
      ui = config.stylix.fonts.sansSerif.name;
    };
    semanticColors = {
      diffAdded = colors.base0B;
      diffRemoved = colors.base0F;
      skill = colors.base0E;
    };
  };
  themeFile = pkgs.writeText "codex-stylix-theme.json" (builtins.toJSON theme);
  python = pkgs.python3.withPackages (ps: [ ps.tomlkit ]);
in
{
  options.stylix.targets.codex.enable = config.lib.stylix.mkEnableTarget "Codex Desktop" true;

  config = lib.mkMerge [
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
    (lib.mkIf (config.stylix.enable && config.stylix.targets.codex.enable) {
      home.activation.applyCodexTheme = lib.hm.dag.entryAfter [ "restoreCodexConfig" ] ''
        run ${python}/bin/python - "$HOME/.codex/config.toml" "${themeFile}" <<'PY'
        import json
        import os
        from pathlib import Path
        import sys
        from tempfile import NamedTemporaryFile

        import tomlkit

        path = Path(sys.argv[1]).resolve(strict=True)
        theme = json.loads(Path(sys.argv[2]).read_text())
        original = path.read_bytes()
        document = tomlkit.parse(original.decode("utf-8"))
        desktop = document.setdefault("desktop", tomlkit.table())
        key = "appearanceDarkChromeTheme"
        if desktop.get(key) != theme:
            desktop[key] = theme
            temporary = None
            try:
                with NamedTemporaryFile(dir=path.parent, delete=False) as output:
                    temporary = Path(output.name)
                    output.write(tomlkit.dumps(document).encode("utf-8"))
                if path.read_bytes() != original:
                    raise SystemExit("Codex configuration changed during activation. Run activation again.")
                os.replace(temporary, path)
            finally:
                if temporary is not None:
                    temporary.unlink(missing_ok=True)
        PY
      '';
    })
  ];
}

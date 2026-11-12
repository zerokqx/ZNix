---
name: packages
description: Add or trace ZNix packages, overlays, inputs, builds, and cache use without weakening reproducibility.
---

# ZNix packages

1. Read `AGENTS.md` and [docs/operations.md](../../../docs/operations.md),
   especially “Жизненный цикл пакета” and “Политика получения пакетов”.
2. Locate ownership before editing: NixOS packages/settings belong in the
   relevant `core/` or `configs/` module; user applications belong under
   `home/`; cross-module policy is limited to `lib/package-policy.nix`.
   Public buildable packages belong in the relevant `flake/` part under
   `perSystem.packages` using its `pkgs` argument. Nixvim is in `flake/nixvim.nix`;
   development tools and the optional VM test are in `flake/quality.nix`.
3. Use packages from the locked `nixpkgs` set. Do not add an input, overlay,
   substituter, trusted key, or `permittedInsecurePackages` entry merely to
   obtain a package. Existing `nix-claude-code` overlay is NixOS-only;
   standalone Home Manager deliberately retains its composition.
4. Trace what Nix will fetch/build before claiming performance or cache reuse:

   ```sh
   nix build .#nixosConfigurations.desktop.config.system.build.toplevel --dry-run --no-link --no-update-lock-file
   nix build .#nixosConfigurations.desktop.config.system.build.toplevel --out-link result-desktop --no-update-lock-file
   nix path-info --closure-size --human-readable ./result-desktop
   ```

   Nix reuses local paths, then signed substituters, then builds misses. Copies
   to another machine transfer only closure paths it lacks; a build is not an
   activation.

5. Run `./scripts/check.sh all`. Treat lock updates, cache policy, and overlays
   as separately reviewable changes; do not use `--no-check-sigs` as a workaround.

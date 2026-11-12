---
name: deployment
description: Build, test, switch, or roll back an authorized ZNix NixOS host while keeping those operations distinct.
---

# Deploy ZNix

1. Read `AGENTS.md` and [docs/operations.md](../../../docs/operations.md).
   Confirm the selected registered host and review the configuration diff.
2. Validate and prepare separately:

   ```sh
   ./scripts/check.sh all
   ./scripts/rebuild.sh build desktop
   # or retain a reviewed closure:
   nix build .#nixosConfigurations.desktop.config.system.build.toplevel --out-link result-desktop --no-update-lock-file
   ```

3. `build` only produces a closure. `test` activates until reboot; `switch`
   activates and selects the boot default. Both mutate the running system, so
   require authorization before the first activation. Once authorization for a
   clear target and operation is retained in this session, do not needlessly
   reconfirm every command; seek new authorization if target or scope changes.
4. For authorized local activation use `./scripts/rebuild.sh test desktop` or
   `./scripts/rebuild.sh switch desktop`. For a reviewed closure, use the
   documented `nixos-rebuild ... --store-path "$(readlink -f result-desktop)"`.
   Remote `--target-host`/`--build-host` requires explicit host/access details;
   do not infer SSH identities or disable signature checks.
5. Keep a console or second SSH connection before remote activation. Recovery
   is `sudo nixos-rebuild switch --rollback` or selecting a prior boot generation;
   it does not roll back home data or databases. Report the action and outcome.

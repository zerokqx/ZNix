---
name: refactoring
description: Make behavior-preserving ZNix module refactors while protecting output, helper, and documentation contracts.
---

# Refactor ZNix

1. Read `AGENTS.md`, [docs/architecture.md](../../../docs/architecture.md),
   and the imports/call sites before moving a module. Use the documented
   `faead27`/`20c0da4` migration baseline only when reviewing that migration.
2. Preserve public contracts:

   - NixOS: `desktop`, `laptop`, `noop`.
   - Home Manager: `zerokqx`, `noop`, `zerok`.
   - Packages/apps: `nixvim`, `menu`, and `default`.

3. Preserve `stateVersion`, hardware settings, host names, existing services,
   and standalone-versus-embedded `noop` behavior unless the task changes one.
4. Extract only real reuse. Keep host details in `hosts/`, composition in
   `profiles/`, system modules in `core/`/`configs/`, and only small shared
   constructors/policy in `lib/`. Do not recreate implicit directory discovery
   or a custom role/options framework.
5. Update the closest documentation or helper test when a user-visible contract
   changes. `scripts/check.sh` and tests must continue to discover explicit
   registry outputs rather than a hard-coded stale list.
6. Run `./scripts/check.sh all` and the relevant dry-build. Inspect the diff
   for accidental lockfile, cache-policy, or activation changes. A passing eval
   does not prove a generated system boots.

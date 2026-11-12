---
name: architecture
description: Navigate or change the explicit ZNix NixOS, Home Manager, profile, and library architecture.
---

# ZNix architecture

1. Read `AGENTS.md` and [docs/architecture.md](../../../docs/architecture.md).
   Keep `flake.lock` unchanged unless the task explicitly updates inputs.
2. Register public outputs only in `hosts/default.nix`. It is an explicit
   registry: a directory with `default.nix` does not create an output. Use the
   existing shapes:

   ```nix
   desktop = mkHost { system = "x86_64-linux"; modules = [ ../profiles/workstation.nix ../profiles/personal.nix ./desktop ]; };
   zerokqx = mkHome { system = "x86_64-linux"; module = ../home/zerokqx; };
   ```

3. Put hardware and host-only services in `hosts/<name>/`; compose repeatable
   workstation/development choices in `profiles/`; retain domain modules in
   `core/` and `configs/`. `lib/default.nix`, `lib/home-modules.nix`, and
   `lib/package-policy.nix` are deliberately small shared constructors/policy,
   not a second option framework.
4. Preserve public contracts: NixOS outputs `desktop`, `laptop`, `noop`; HM
   outputs `zerokqx`, `noop`, and `zerok` aliasing `zerokqx`. Embedded `noop`
   intentionally combines the personal profile with `home/noop`; standalone `noop` remains its
   own Home Manager module.
5. For structural changes run `./scripts/check.sh all`; read
   [docs/operations.md](../../../docs/operations.md) for builds and activation.
   Evaluation is not a build or a hardware test.

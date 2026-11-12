---
name: architecture
description: Navigate or change the explicit ZNix NixOS, Home Manager, profile, and library architecture.
---

# ZNix architecture

1. Read `AGENTS.md` and [docs/architecture.md](../../../docs/architecture.md).
   Keep `flake.lock` unchanged unless the task explicitly updates inputs.
2. `flake.nix` is a small `flake-parts` entrypoint. `hosts/default.nix` owns
   top-level NixOS and standalone Home Manager outputs; `flake/quality.nix`
   owns development and validation outputs through `perSystem`. A
   directory with `default.nix` never creates an output automatically. Use the
   existing shapes:

   ```nix
   desktop = inputs.nixpkgs.lib.nixosSystem {
     specialArgs = { inherit inputs; };
     modules = [ ./desktop ];
   };
   zerokqx = mkHome ../home/zerokqx;
   ```

3. Each `hosts/<name>/default.nix` explicitly imports its base configuration,
   selected profiles and hardware module. Put hardware and host-only services
   there; compose repeatable choices in `profiles/`; retain domain modules in
   `core/` and `configs/`. `lib/home-modules.nix` and `lib/package-policy.nix`
   are deliberately small shared policy, not a second option framework.
   `workstation` and `development` are independent selections.
4. Preserve public contracts: NixOS outputs `desktop`, `laptop`, `noop`; HM
   outputs `zerokqx`, `noop`, and `zerok` aliasing `zerokqx`. Embedded `noop`
   intentionally combines the personal profile with `home/noop`; standalone `noop` remains its
   own Home Manager module.
5. Keep ordinary path imports. Do not publish a `flake.modules` registry unless
   it removes real repetition; it currently only adds a lookup. Use `perSystem`
   for packages, apps, development shell, checks and formatter, never for
   `nixosConfigurations`. Extend an existing part first. If a separate concern
   needs a new `flake/<name>.nix`, write an ordinary flake-parts module with
   `perSystem` or `flake` attributes and add its path to `flake.nix` imports.
6. For structural changes run `./scripts/check.sh all`; read
   [docs/operations.md](../../../docs/operations.md) for builds and activation.
   Evaluation is not a build or a hardware test.

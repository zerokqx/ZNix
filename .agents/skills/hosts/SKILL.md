---
name: hosts
description: Register or modify explicit ZNix NixOS and Home Manager hosts without changing another machine's hardware settings.
---

# ZNix hosts

1. Read `AGENTS.md`, `hosts/default.nix`, and
   [docs/architecture.md](../../../docs/architecture.md). Current NixOS keys
   are `desktop`, `laptop`, `noop`; their `networking.hostName` values are
   `nixos-pc`, `nixos-laptop`, and `nixos`.
2. A new NixOS machine needs its own `hosts/<name>/default.nix` and hardware
   configuration, then one explicit registry entry:

   ```nix
   name = mkHost {
     system = "x86_64-linux";
     modules = [ ../profiles/workstation.nix ../profiles/personal.nix ./name ];
   };
   ```

   A standalone Home Manager output similarly uses `mkHome { system = ...;
   module = ../home/<name>; };`. There is no directory auto-discovery.
3. Never copy UUIDs, disks, swap/resume offsets, monitors, or host keys from
   another host. Keep those settings in the machine module; add common behavior
   to an existing profile only when it is genuinely shared.
4. Preserve the `noop` distinction: its NixOS configuration combines `home/zerokqx` with
   `home/noop`, while standalone HM `noop` uses only `home/noop`.
5. Run `./scripts/check.sh eval` for all registered systems and homes, then a
   separate requested host build from [docs/operations.md](../../../docs/operations.md).
   Do not activate a host without authorization.

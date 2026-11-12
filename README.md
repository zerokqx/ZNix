# ZNix

Personal NixOS and Home Manager configuration for three x86_64 Linux machines,
with Hyprland, Dank Material Shell, Fish and Nixvim. Versions are pinned by
`flake.lock`; the main system stack is NixOS 26.05.

| Flake host | System hostname | Profiles |
| --- | --- | --- |
| `desktop` | `nixos-pc` | workstation + personal |
| `laptop` | `nixos-laptop` | workstation + personal |
| `noop` | `nixos` | workstation + personal + noop Home Manager additions |

`hosts/default.nix` explicitly registers systems and standalone Home Manager
outputs (`zerokqx`, `noop`, and the `zerok` alias). Host directories contain plain
NixOS modules and hardware settings. `profiles/` composes features; `core/` and
`configs/` retain system modules; `home/` contains user settings. Shared
constructors and package policy live in `lib/`.

## Validate and build

```sh
nix develop
./scripts/check.sh all
nix flake check --no-build --no-update-lock-file
nix flake check --no-update-lock-file
./scripts/rebuild.sh build desktop
```

Use `check.sh all --base <commit>` to check the complete change range. Review and
stage newly referenced flake files explicitly; no rebuild script stages files.
The generic `rebuild` command now builds by default. Named `rebuild-desktop`,
`rebuild-laptop`, and `rebuild-noop` devenv commands still activate their hosts;
their `-test` variants also activate the running system. Use them deliberately.
The Bash wrapper resolves the current hostname to a unique registered host.
Building does not apply a configuration or prove hardware compatibility.

## Agent setup

Read [AGENTS.md](AGENTS.md) and the project
[install skill](.agents/skills/install/SKILL.md), then choose your environment:

```sh
python3 scripts/install-skills.py --environment codex
python3 scripts/install-skills.py --environment claude
```

Codex discovers `.agents/skills` natively. Claude uses relative per-skill symlinks;
installation is repeatable and refuses conflicts. Agent settings remain local.

## Register a new host

Create a hardware module under `hosts/<name>/`, then register it explicitly in
`hosts/default.nix` with `mkHost`, selecting the needed profiles. Register a
standalone Home Manager configuration with `mkHome` when needed. See
[Architecture and adding hosts](docs/architecture.md).

## Documentation

- [Architecture and adding hosts](docs/architecture.md)
- [Checks, package acquisition, remote builds, deployment and rollback](docs/operations.md)
- [Refactoring report and validation limits](docs/refactoring-report.md)

Hardware UUIDs, resume offsets and monitors are machine-specific. Other CPU
architectures require package/input compatibility checks. Existing translations
in `docs/` are historical setup guides; use the documents above for the current
layout and workflows. Activation and destructive system changes require the
owner's explicit approval.

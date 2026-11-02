# ZNix

Personal NixOS and Home Manager configuration for x86_64 Linux, with Hyprland, Dank Material Shell, Fish and Nixvim. See [AGENTS.md](AGENTS.md) for the repository map and development conventions.

## Layout

- `flake.nix`, `flake.lock`: inputs and pinned versions (the main NixOS stack follows 26.05).
- `hosts/desktop`, `hosts/laptop`, `hosts/noop`: machine-specific configurations and hardware.
- `configuration.nix`, `core/`, `configs/`: shared system configuration and modules.
- `home/zerokqx/`, `home/noop/`: Home Manager modules; the former contains the main user configuration.
- `rust/znix-menu/`: menu source; the flake also provides `nixvim` and `menu` packages and apps.
- `devenv.nix`: development shell and convenience commands.

## Build and apply

Hardware configurations, disk paths and monitor settings are machine-specific. Adapt them before using a host on another machine.

```sh
nix flake check --show-trace
nix build .#nixosConfigurations.desktop.config.system.build.toplevel --no-link
sudo nixos-rebuild switch --flake .#desktop
```

Replace `desktop` with the intended host. Building does not apply the configuration. The `rebuild*` scripts in `devenv.nix` run `git add .` before rebuilding; inspect the working tree before using them.

Home Manager is integrated into the NixOS configuration. The flake also exports standalone `homeConfigurations`; avoid activating one over the NixOS-managed profile without understanding the profile change.

The Fish prompt displays the current path in color. New modules must be added to the relevant `imports`; host and Home Manager directories are discovered by `hosts/default.nix`.

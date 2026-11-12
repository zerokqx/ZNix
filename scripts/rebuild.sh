#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: rebuild.sh [build|switch|test|vm] [HOST]
       rebuild.sh HOST

Build is the default. Switch activates and sets the boot default. Test activates
until the next boot. VM builds and launches a guest.
With no HOST, match this machine's hostname to a registered NixOS host.
EOF
}

fail() {
  printf '%s\n' "$*" >&2
  exit 1
}

action=build
case "${1:-}" in
  -h|--help) usage; exit 0 ;;
  build|switch|test|vm) action=$1; shift ;;
  -*) fail "Unknown option '$1'. See rebuild.sh --help." ;;
esac
(( $# <= 1 )) || fail 'Expected at most one host. See rebuild.sh --help.'

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
for command in nix python3; do
  command -v "$command" >/dev/null || fail "Required command missing: $command"
done

if (( $# == 0 )); then
  command -v hostname >/dev/null || fail 'Required command missing: hostname'
  local_hostname=$(hostname -s)
  registry=$(nix eval --json --no-update-lock-file .#nixosConfigurations \
    --apply 'builtins.mapAttrs (_: host: host.config.networking.hostName)')
  host=$(python3 -c '
import json, sys

hostname = sys.argv[1]
matches = [name for name, value in json.load(sys.stdin).items() if value == hostname]
if len(matches) != 1:
    raise SystemExit(f"Expected one registered host matching {hostname!r}; found {matches}. Pass HOST explicitly.")
print(matches[0])
' "$local_hostname" <<< "$registry")
else
  host=$1
  registry=$(nix eval --json --no-update-lock-file .#nixosConfigurations --apply builtins.attrNames)
  python3 -c '
import json, sys

hosts = json.load(sys.stdin)
if sys.argv[1] not in hosts:
    registered = ", ".join(hosts)
    raise SystemExit(f"Unknown host {sys.argv[1]!r}. Registered hosts: {registered}")
' "$host" <<< "$registry"
fi

case "$action" in
  build)
    exec nix build --no-update-lock-file --no-link --show-trace \
      ".#nixosConfigurations.\"$host\".config.system.build.toplevel"
    ;;
  switch|test)
    for command in sudo nixos-rebuild; do
      command -v "$command" >/dev/null || fail "Required command missing: $command"
    done
    exec sudo nixos-rebuild "$action" --flake ".#$host" --no-update-lock-file --show-trace
    ;;
  vm)
    vm_dir=$(mktemp -d)
    trap 'rm -rf -- "$vm_dir"' EXIT
    nix build --no-update-lock-file --show-trace --out-link "$vm_dir/result" \
      ".#nixosConfigurations.\"$host\".config.system.build.vm"
    shopt -s nullglob
    launchers=("$vm_dir"/result/bin/run-*-vm)
    (( ${#launchers[@]} == 1 )) || fail 'Expected one VM launcher in the build output.'
    "${launchers[0]}"
    ;;
esac

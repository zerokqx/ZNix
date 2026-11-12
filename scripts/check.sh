#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: check.sh [syntax|static|eval|all] [--base REF]

Syntax parses Nix and Bash. Static checks formatting on temporary copies of
changed files relative to REF (HEAD by default), checks the diff for whitespace
and conflict markers, runs ShellCheck, and runs workflow tests.
Eval resolves the derivation paths of every registered system and home.
The default is all.
EOF
}

fail() {
  printf '%s\n' "$*" >&2
  exit 1
}

require() {
  for command in "$@"; do
    command -v "$command" >/dev/null || fail "Required command missing: $command (use nix develop)"
  done
}

phase=all
base=HEAD
case "${1:-}" in
-h | --help)
  usage
  exit 0
  ;;
syntax | static | eval | all)
  phase=$1
  shift
  ;;
esac
if [[ ${1:-} == --base && $# == 2 ]]; then
  base=$2
  shift 2
fi
(($# == 0)) || fail 'Invalid arguments. See check.sh --help.'

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
export GIT_OPTIONAL_LOCKS=0

syntax() {
  require git nix-instantiate
  printf '%s\n' 'Checking Nix and Bash syntax'
  git ls-files --cached --others --exclude-standard -z -- '*.nix' '*.sh' |
    while IFS= read -r -d '' file; do
      [[ -f $file ]] || continue
      case "$file" in
      *.nix) nix-instantiate --parse "./$file" >/dev/null ;;
      *.sh) bash -n "./$file" ;;
      esac
    done
}

static() (
  require git treefmt shellcheck python3
  local commit
  commit=$(git rev-parse --verify --end-of-options "$base^{commit}") || fail "Unknown base commit: $base"

  git -c diff.autoRefreshIndex=false diff --check "$commit"
  printf 'Checking changed-file formatting against %s\n' "$base"
  local file temporary
  local -a files=()
  local -a formats=('*.nix' '*.sh' '.envrc' '*.md' '*.yaml' '*.yml' '*.json' '*.toml')
  temporary=$(mktemp -d)
  trap 'rm -rf -- "$temporary"' EXIT
  {
    git -c diff.autoRefreshIndex=false diff --name-only --diff-filter=ACMRT -z "$commit" -- "${formats[@]}" || exit 1
    git ls-files --others --exclude-standard -z -- "${formats[@]}" || exit 1
  } | sort -zu >"$temporary/files"
  while IFS= read -r -d '' file; do
    [[ -f $file && ! -L $file ]] || continue
    files+=("$file")
  done <"$temporary/files"
  if ((${#files[@]})); then
    mkdir -- "$temporary/source"
    cp --parents -- "${files[@]}" "$temporary/source/"
    # treefmt check mode can rewrite files before reporting a failure.
    (
      cd -- "$temporary/source"
      treefmt --tree-root "$temporary/source" --walk filesystem --ci -- "${files[@]}"
    )
  fi

  printf '%s\n' 'Running ShellCheck and workflow tests'
  git ls-files --cached --others --exclude-standard -z -- '*.sh' |
    while IFS= read -r -d '' file; do
      [[ -f $file ]] || continue
      shellcheck "./$file"
    done
  python3 -B -m unittest discover -s tests
)

eval_outputs() {
  require nix python3
  printf '%s\n' 'Evaluating NixOS and Home Manager derivations'
  local collection attribute names name drv
  for collection in nixosConfigurations homeConfigurations; do
    case "$collection" in
    nixosConfigurations) attribute=config.system.build.toplevel.drvPath ;;
    homeConfigurations) attribute=activationPackage.drvPath ;;
    esac
    names=$(nix eval --json --no-update-lock-file ".#$collection" --apply builtins.attrNames |
      python3 -c 'import json, sys; print(*json.load(sys.stdin), sep="\n")') ||
      fail "Could not read $collection. New files referenced by this flake must be added to Git explicitly."
    [[ -n $names ]] || fail "No entries in $collection."
    while IFS= read -r name; do
      drv=$(nix eval --raw --no-update-lock-file ".#$collection.\"$name\".$attribute") ||
        fail "Could not evaluate $collection.$name. New files referenced by this flake must be added to Git explicitly."
      printf '%s.%s %s\n' "$collection" "$name" "$drv"
    done <<<"$names"
  done
}

case "$phase" in
syntax) syntax ;;
static) static ;;
eval) eval_outputs ;;
all)
  syntax
  static
  eval_outputs
  ;;
esac

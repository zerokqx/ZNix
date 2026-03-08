#!/usr/bin/env bash
  set -euo pipefail

ROOT_DIR="${1:-.}"
FLAKE_NIX="$ROOT_DIR/flake.nix"
FLAKE_LOCK="$ROOT_DIR/flake.lock"

if [[ ! -f "$FLAKE_NIX" ]]; then
  echo "error: flake.nix not found at $FLAKE_NIX" >&2
  exit 1
fi

# Parse top-level inputs from flake.nix (inputs = { ... };)
inputs_raw="$({
  awk '
    BEGIN { in_inputs = 0; depth = 0 }
    {
      line = $0
      sub(/#.*/, "", line)

      if (!in_inputs) {
        if (line ~ /^[[:space:]]*inputs[[:space:]]*=[[:space:]]*\{/) {
          in_inputs = 1
          depth = 1
        }
        next
      }

      opens = gsub(/\{/, "{", line)
      closes = gsub(/\}/, "}", line)

      if (depth == 1) {
        if (match(line, /^[[:space:]]*([A-Za-z0-9_-]+)[[:space:]]*=[[:space:]]*/, m)) {
          print m[1]
        } else if (match(line, /^[[:space:]]*([A-Za-z0-9_-]+)\.[A-Za-z0-9_.-]+[[:space:]]*=[[:space:]]*/, m)) {
          print m[1]
        }
      }

      depth += opens - closes
      if (depth <= 0) {
        exit
      }
    }
  ' "$FLAKE_NIX"
} | awk 'NF' | sort -u)"

# Try to extract nixpkgs channel/ref from flake.nix first.
nixpkgs_ref="$(sed -nE 's/^[[:space:]]*nixpkgs\.url[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' "$FLAKE_NIX" | head -n1)"
nixpkgs_version="unknown"
if [[ -n "$nixpkgs_ref" ]]; then
  nixpkgs_version="${nixpkgs_ref##*/}"
fi

# Try to extract locked nixpkgs revision from flake.lock if present.
nixpkgs_rev="unknown"
if [[ -f "$FLAKE_LOCK" ]]; then
  nixpkgs_rev="$(awk '
    BEGIN { in_nixpkgs = 0 }
    /"nixpkgs"[[:space:]]*:[[:space:]]*\{/ { in_nixpkgs = 1 }
    in_nixpkgs && /"rev"[[:space:]]*:/ {
      if (match($0, /"rev"[[:space:]]*:[[:space:]]*"([^"]+)"/, m)) {
        print m[1]
        exit
      }
    }
    in_nixpkgs && /\}[[:space:]]*,?[[:space:]]*$/ { in_nixpkgs = 0 }
  ' "$FLAKE_LOCK" | head -n1)"
  nixpkgs_rev="${nixpkgs_rev:-unknown}"
fi

# Count non-hidden .nix files (exclude any path component starting with dot).
nix_file_count="$(find "$ROOT_DIR" -path "$ROOT_DIR/.git" -prune -o -path '*/.*' -prune -o -type f -name '*.nix' -print | wc -l | tr -d ' ')"
inputs_count="$(printf '%s\n' "$inputs_raw" | awk 'NF' | wc -l | tr -d ' ')"

blue="\033[1;38;5;39m"
cyan="\033[1;38;5;45m"
reset="\033[0m"

repeat_char() {
  local count="$1"
  local char="$2"
  printf '%*s' "$count" '' | tr ' ' "$char"
}

print_row() {
  local text="$1"
  printf "%b\n" "$text"
}

print_kv() {
  local icon="$1"
  local key="$2"
  local value="$3"
  printf "%b%-24s  ${blue}%s${reset}\n" "${icon} " "$key" "$value"
}

inner_width=80
title="✨ ZNix Flake Report ✨"
title_len=${#title}
if (( title_len + 2 > inner_width )); then
  title="${title:0:inner_width-1}…"
  title_len=${#title}
fi
left_fill=$(( (inner_width - title_len - 2) / 2 ))
right_fill=$(( inner_width - title_len - 2 - left_fill ))
top_line="$(repeat_char "$left_fill" "=") ${title} $(repeat_char "$right_fill" "=")"
bottom_line="$(repeat_char "$inner_width" "=")"

printf "${blue}+%s+${reset}\n" "$top_line"
print_row "📦 Inputs used (${inputs_count}):"
while IFS= read -r input; do
  [[ -n "$input" ]] && print_row "  🔹 $input"
done <<< "$inputs_raw"
print_kv "🧭" "nixpkgs ref" "${nixpkgs_ref:-unknown}"
print_kv "🏷️" "nixpkgs version" "$nixpkgs_version"
print_kv "🔒" "nixpkgs locked rev" "$nixpkgs_rev"
print_kv "📄" "Non-hidden .nix files" "$nix_file_count"
print_row "🚀 Ready to hack Nix"
printf "${blue}+%s+${reset}\n" "$bottom_line"

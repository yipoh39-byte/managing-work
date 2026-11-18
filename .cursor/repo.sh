#!/usr/bin/env bash
# Shared helpers for Cloud Agent install and start. Resolves checkouts from
# this script's repository so the commands work when the workspace root is the
# primary repo or a parent directory that contains both clones.

cursor_primary_repo() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
  (cd "$script_dir/.." && pwd)
}

cursor_find_repo() {
  local name="$1"
  local marker="$2"
  local primary="$3"
  local candidate
  for candidate in \
    "$primary/../$name" \
    "$(dirname "$primary")/$name" \
    "/agent/repos/$name" \
    "$PWD/$name" \
    "$PWD/repos/$name"
  do
    if [[ -e "$candidate/$marker" ]]; then
      (cd "$candidate" && pwd)
      return 0
    fi
  done
  printf 'Could not find repository %s (marker %s)\n' "$name" "$marker" >&2
  return 1
}

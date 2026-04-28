#!/usr/bin/env bash
# Install one stacks/* profile into the project root.
#
# Usage: ./scripts/install-stack.sh <typescript|python|go>
#
# Idempotent: re-running with the same stack is a no-op. Switching stacks
# refuses unless --force is passed.

set -euo pipefail

stack="${1:-}"
force="${2:-}"

if [[ -z "$stack" ]]; then
  echo "usage: $0 <typescript|python|go> [--force]" >&2
  exit 2
fi

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
profile_dir="$repo_root/stacks/$stack"

if [[ ! -d "$profile_dir" ]]; then
  echo "error: unknown stack '$stack'. available:" >&2
  ls -1 "$repo_root/stacks" >&2
  exit 2
fi

marker="$repo_root/.harness-stack"
if [[ -f "$marker" ]]; then
  current="$(cat "$marker")"
  if [[ "$current" == "$stack" ]]; then
    echo "stack '$stack' already installed."
    exit 0
  fi
  if [[ "$force" != "--force" ]]; then
    echo "error: stack '$current' is already installed. pass --force to switch." >&2
    exit 1
  fi
fi

echo "installing stack: $stack"
shopt -s dotglob
for path in "$profile_dir"/*; do
  name="$(basename "$path")"
  [[ "$name" == "profile.json" ]] && continue
  [[ "$name" == "grade.sh"    ]] && continue   # invoked in place
  dest="${name%.template}"
  cp -R "$path" "$repo_root/$dest"
  echo "  + $dest"
done

echo "$stack" > "$marker"
echo "done. run ./scripts/harness-check.sh"

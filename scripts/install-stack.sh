#!/usr/bin/env bash
# Install one stacks/* profile into the project root and (by default)
# strip away the polyglot scaffolding that this repo no longer needs.
#
# Usage: ./scripts/install-stack.sh <stack> [--keep-siblings] [--force]
#
#   <stack>           name of a directory under stacks/
#   --keep-siblings   leave stacks/<other>/ in place (default: remove them)
#   --force           switch from a previously installed stack
#
# After install, the only stacks/ leaf retained is stacks/<stack>/ which
# still hosts profile.json + grade.sh (read in place by harness-check.sh
# and gc-refactor.sh). install-stack.sh removes itself too — once you've
# committed to a stack, switching is a re-template, not a re-install.

set -euo pipefail

stack=""
keep_siblings=0
force=0
for arg in "$@"; do
  case "$arg" in
    --keep-siblings) keep_siblings=1 ;;
    --force)         force=1 ;;
    --*)             echo "unknown flag: $arg" >&2; exit 2 ;;
    *)               stack="$arg" ;;
  esac
done

if [[ -z "$stack" ]]; then
  echo "usage: $0 <stack> [--keep-siblings] [--force]" >&2
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
  if [[ $force -eq 0 ]]; then
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

if [[ $keep_siblings -eq 0 ]]; then
  echo "removing sibling stacks (pass --keep-siblings to keep)"
  for sibling in "$repo_root/stacks"/*; do
    name="$(basename "$sibling")"
    [[ "$name" == "$stack" ]] && continue
    rm -rf "$sibling"
    echo "  - stacks/$name"
  done
  # Prune the active stack down to just profile.json + grade.sh — the
  # other files have been copied into the project root and we don't want
  # them double-linted under stacks/<stack>/.
  for path in "$profile_dir"/*; do
    name="$(basename "$path")"
    [[ "$name" == "profile.json" ]] && continue
    [[ "$name" == "grade.sh"     ]] && continue
    rm -rf "$path"
    echo "  - stacks/$stack/$name"
  done
  rm -f "$repo_root/scripts/install-stack.sh"
  echo "  - scripts/install-stack.sh (a single-stack repo doesn't need it)"
fi

echo "done. run ./scripts/harness-check.sh"

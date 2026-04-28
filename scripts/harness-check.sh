#!/usr/bin/env bash
# Run every computational sensor for the installed stack, in order.
# Stops at the first failure unless --keep-going.

set -uo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
marker="$repo_root/.harness-stack"

if [[ ! -f "$marker" ]]; then
  echo "no stack installed. run ./scripts/install-stack.sh <stack> first." >&2
  exit 2
fi

stack="$(cat "$marker")"
profile="$repo_root/stacks/$stack/profile.json"

if [[ ! -f "$profile" ]]; then
  echo "missing profile for stack '$stack'." >&2
  exit 2
fi

keep_going=0
[[ "${1:-}" == "--keep-going" ]] && keep_going=1

# Order matters: cheapest first, behavior-checking last.
order=(format lint typecheck policy deadcode test audit)

failed=()
for sensor in "${order[@]}"; do
  cmd="$(jq -r ".sensors.\"$sensor\" // empty" "$profile")"
  if [[ -z "$cmd" ]]; then
    continue
  fi
  echo
  echo "[$sensor] $cmd"
  if ! bash -c "$cmd"; then
    failed+=("$sensor")
    if [[ $keep_going -eq 0 ]]; then
      echo
      echo "harness failed at: $sensor" >&2
      exit 1
    fi
  fi
done

if [[ ${#failed[@]} -gt 0 ]]; then
  echo
  echo "harness failed: ${failed[*]}" >&2
  exit 1
fi

echo
echo "harness ok ($stack)"

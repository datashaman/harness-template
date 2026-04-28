#!/usr/bin/env bash
# Create the labels the harness workflows expect. Run once after creating
# a repo from this template. GitHub does not propagate labels from
# template repos, so the issue template's `labels:` field silently drops
# anything that doesn't already exist on the target repo.
#
# Requires: gh CLI authenticated against the target repo.
# Usage:    ./scripts/setup-github-labels.sh [owner/repo]
#           (defaults to the current repo via `gh repo view`)

set -euo pipefail

repo="${1:-}"
if [[ -z "$repo" ]]; then
  repo="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
fi

ensure() {
  local name="$1" color="$2" desc="$3"
  if gh label list --repo "$repo" --limit 200 | awk -F'\t' '{print $1}' | grep -qx "$name"; then
    echo "  · $name (already exists)"
  else
    gh label create "$name" --repo "$repo" --color "$color" --description "$desc" >/dev/null
    echo "  + $name"
  fi
}

echo "ensuring labels in $repo:"
ensure "agent:implement" "0E8A16" "Trigger implement-issue workflow"
ensure "agent:generated" "5319E7" "PR opened by harness-bot from a spec issue"

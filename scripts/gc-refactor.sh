#!/usr/bin/env bash
# Garbage-collection entry point. Invoked by .github/workflows/gc.yml on a
# nightly cron, or locally on demand.
#
# Reads harness/grades.yml, picks the lowest-graded files, and dispatches
# each to its configured fixer (a Claude Code or Codex slash command).
#
# Each fixer is responsible for opening ONE small PR. If a fixer can't make
# a mechanical fix, it logs and skips — never asks for human input.

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

agent="${HARNESS_AGENT:-claude}"   # claude | codex
max_prs="${HARNESS_MAX_PRS:-5}"

echo "harness gc: agent=$agent max_prs=$max_prs"

# Build the candidate list. The grading script is stack-specific; each stack
# may provide stacks/<stack>/grade.sh that prints `<file>\t<grade>\t<weakest_grade>`.
stack="$(cat .harness-stack 2>/dev/null || echo "")"
grader="stacks/$stack/grade.sh"

if [[ ! -x "$grader" ]]; then
  echo "no grader for stack '$stack' — nothing to do."
  exit 0
fi

candidates="$("$grader" | sort -k2 -n | head -n "$max_prs")"

if [[ -z "$candidates" ]]; then
  echo "no refactor candidates."
  exit 0
fi

while IFS=$'\t' read -r file grade weakest; do
  echo
  echo "→ $file (grade $grade, weakest: $weakest)"
  case "$agent" in
    claude)
      claude --print --dangerously-skip-permissions \
        "/gc-refactor $weakest $file" || echo "  fixer failed; skipping"
      ;;
    codex)
      codex exec --quiet \
        "Apply the '$weakest' fixer from harness/grades.yml to $file. \
         Open a small PR. If you can't make a mechanical fix, exit 0 \
         without changes." || echo "  fixer failed; skipping"
      ;;
    *)
      echo "unknown agent '$agent'" >&2
      exit 2
      ;;
  esac
done <<< "$candidates"

#!/usr/bin/env bash
# Stub grader. Outputs `<file>\t<composite_score>\t<weakest_grade>` for
# every source file. Read by scripts/gc-refactor.sh.

set -euo pipefail
export LC_ALL=C
cd "$(dirname "$0")/../.."

shopt -s nullglob globstar
for f in src/**/*.go; do
  [[ -f "$f" ]] || continue
  [[ "$f" == *_test.go ]] && continue

  lines=$(wc -l < "$f" | tr -d ' ')
  legibility=$(awk -v l="$lines" 'BEGIN{ s=1-(l/500); if(s<0) s=0; if(s>1) s=1; printf "%.2f", s }')

  composite="$legibility"
  weakest="legibility"

  printf "%s\t%s\t%s\n" "$f" "$composite" "$weakest"
done

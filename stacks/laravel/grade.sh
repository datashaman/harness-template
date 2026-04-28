#!/usr/bin/env bash
# Stub grader for Laravel. Outputs `<file>\t<composite_score>\t<weakest_grade>`
# for every source file under app/. Read by scripts/gc-refactor.sh.

set -euo pipefail
export LC_ALL=C
cd "$(dirname "$0")/../.."

shopt -s nullglob globstar
for f in app/**/*.php; do
  [[ -f "$f" ]] || continue
  [[ "$(basename "$f")" == *Test.php ]] && continue

  lines=$(wc -l < "$f" | tr -d ' ')
  legibility=$(awk -v l="$lines" 'BEGIN{ s=1-(l/400); if(s<0) s=0; if(s>1) s=1; printf "%.2f", s }')

  composite="$legibility"
  weakest="legibility"

  printf "%s\t%s\t%s\n" "$f" "$composite" "$weakest"
done

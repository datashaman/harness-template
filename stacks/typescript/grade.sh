#!/usr/bin/env bash
# Stub grader. Outputs `<file>\t<composite_score>\t<weakest_grade>` for
# every source file. Read by scripts/gc-refactor.sh.
#
# v1: legibility (lines/complexity proxy) + api_surface (barrel check).
# Refine each grade by reading harness/grades.yml and adding a function.

set -euo pipefail
export LC_ALL=C
cd "$(dirname "$0")/../.."

shopt -s nullglob globstar
for f in src/**/*.ts src/**/*.tsx; do
  [[ -f "$f" ]] || continue
  [[ "$f" == *.test.ts || "$f" == *.test.tsx ]] && continue

  lines=$(wc -l < "$f" | tr -d ' ')
  legibility=$(awk -v l="$lines" 'BEGIN{ s=1-(l/400); if(s<0) s=0; if(s>1) s=1; printf "%.2f", s }')

  dir="$(dirname "$f")"
  if [[ -f "$dir/index.ts" ]]; then api_surface=1.00; else api_surface=0.50; fi

  composite=$(awk -v a="$legibility" -v b="$api_surface" 'BEGIN{ print (a<b)?a:b }')
  weakest=$(awk -v a="$legibility" -v b="$api_surface" 'BEGIN{ print (a<b)?"legibility":"api_surface" }')

  printf "%s\t%s\t%s\n" "$f" "$composite" "$weakest"
done

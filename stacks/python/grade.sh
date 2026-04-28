#!/usr/bin/env bash
# Stub grader. Outputs `<file>\t<composite_score>\t<weakest_grade>` for
# every source file. Read by scripts/gc-refactor.sh.

set -euo pipefail
export LC_ALL=C
cd "$(dirname "$0")/../.."

shopt -s nullglob globstar
for f in src/**/*.py; do
  [[ -f "$f" ]] || continue
  [[ "$(basename "$f")" == test_*.py || "$f" == *_test.py ]] && continue

  lines=$(wc -l < "$f" | tr -d ' ')
  legibility=$(awk -v l="$lines" 'BEGIN{ s=1-(l/400); if(s<0) s=0; if(s>1) s=1; printf "%.2f", s }')

  dir="$(dirname "$f")"
  if [[ -f "$dir/__init__.py" ]] && grep -q '__all__' "$dir/__init__.py" 2>/dev/null; then
    api_surface=1.00
  else
    api_surface=0.50
  fi

  composite=$(awk -v a="$legibility" -v b="$api_surface" 'BEGIN{ print (a<b)?a:b }')
  weakest=$(awk -v a="$legibility" -v b="$api_surface" 'BEGIN{ print (a<b)?"legibility":"api_surface" }')

  printf "%s\t%s\t%s\n" "$f" "$composite" "$weakest"
done

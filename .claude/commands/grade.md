---
description: Print the current quality grades for a file
argument-hint: <file>
---

For the file `$1`:

1. Read `harness/grades.yml` for the grade definitions.
2. Compute (or estimate, if no grader is available) each grade for the file.
3. Print a table: `grade | weight | score | threshold | status (ok|below)`.
4. If any grade is below threshold, suggest the matching `fixer` from grades.yml.

Don't open a PR. This is a read-only command.

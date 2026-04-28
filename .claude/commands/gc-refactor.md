---
description: Apply a single mechanical refactor against a quality grade
argument-hint: <grade> <file>
---

Read `harness/grades.yml`. The grade requested is `$1`. The file is `$2`.

Constraints:
- One PR. One grade. One file (or one tightly-scoped set, max 5 files).
- The PR must be reviewable in under a minute.
- If the fix isn't mechanical — i.e., it requires a judgment call about behavior — exit without changes and explain why in the run log.
- Run `./scripts/harness-check.sh` before opening the PR. It must pass.

PR description template:

```
gc: $1 grade on $2

Weakest grade: $1 (threshold from harness/grades.yml)
Mechanical fix applied: <one line>

Reviewable in: <estimate>
```

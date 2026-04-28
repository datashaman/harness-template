---
description: Run all computational sensors for the installed stack
---

Run `./scripts/harness-check.sh` and report the result. If any sensor fails:

1. Read the failing sensor's output.
2. Identify the root cause (don't paper over it).
3. Either fix the code, or — if the rule is wrong — amend `harness/policies/` with a one-line rationale and re-run.

Don't claim done until every sensor is green.

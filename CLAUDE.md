# Claude Code instructions

This file is the Claude-Code-specific entry point. The authoritative golden principles live in `AGENTS.md` — read that first. This file adds Claude-Code-only operating notes.

## Read these before acting

1. `AGENTS.md` — golden principles.
2. `docs/architecture.md` — module boundaries.
3. `docs/conventions.md` — naming, errors, logging.
4. `docs/harness.md` — what each sensor checks and how to run it.

## Workflow

- After any non-trivial edit, run `./scripts/harness-check.sh`. Don't claim done until it passes.
- For refactors, prefer `/gc-refactor` to scope the diff against `harness/grades.yml`.
- Use `/grade` to print the current quality grades for the file you're editing.

## Tool preferences

- Edits: `Edit` and `Write`. Don't use `sed`/`awk` from Bash.
- Search: ripgrep via Bash, or the `Explore` agent for broad sweeps.
- Inferential review: `/review` (Claude) or `codex review` (Codex). Both run in CI; locally, run one before declaring done on a behavior change.

## When the harness disagrees with you

The harness is authoritative. If you believe a sensor is wrong:

1. Reproduce the failure.
2. Either fix the code, or amend the rule in `harness/policies/` **in the same PR** with a one-line rationale.

Silently disabling a check is a regression worse than the original bug.

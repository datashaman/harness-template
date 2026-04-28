# The harness

The harness is the set of guides and sensors that keep the codebase legible to both humans and agents. It has three layers, ordered by cost.

## 1. Feedforward (free, runs in your head)

- `AGENTS.md` — golden principles.
- `docs/architecture.md` — module boundaries and invariants.
- `docs/conventions.md` — naming, errors, logging.
- `harness/policies/` — opinionated rules expressed as semgrep / custom-linter patterns.

## 2. Computational sensors (milliseconds–seconds)

Run on every change. If any fail, the PR doesn't land.

| Sensor              | What it checks                                  | Where it lives                  |
|---------------------|-------------------------------------------------|---------------------------------|
| Format              | Style, layout                                   | `stacks/*/format`               |
| Lint                | Code smells, unused symbols                     | `stacks/*/lint`                 |
| Type check          | Type correctness                                | `stacks/*/typecheck`            |
| Unit + integration  | Behavior                                        | `stacks/*/test`                 |
| Architecture        | Module-boundary invariants                      | `stacks/*/checks/architecture.*`|
| Policy              | Cross-cutting rules (semgrep)                   | `harness/policies/`             |
| Dead code           | Unused exports / files                          | `stacks/*/deadcode`             |
| Dependency security | Known CVEs in dependencies                      | `stacks/*/audit`                |

Run all of them locally with `./scripts/harness-check.sh`.

## 3. Inferential sensors (minutes, sampled)

Run in CI and on demand. Slower, smarter, occasionally wrong — treat their output as input to your judgment, not as a gate.

- **Claude Code review** (`/review` locally, `.github/workflows/review.yml` in CI).
- **Codex review** (`codex review`, same workflow).
- Disagreements: deterministic sensors win. If both inferential reviewers flag the same thing, take it seriously.

## 4. Garbage collection (nightly, in the background)

`scripts/gc-refactor.sh` runs on a schedule (`.github/workflows/gc.yml`). It:

1. Re-scores every module against `harness/grades.yml`.
2. Picks the lowest-graded files that have a clear, mechanical fix.
3. Opens a small refactor PR per fix, with the failing grade in the description.

These PRs should be reviewable in under a minute. If they aren't, the GC step is too ambitious — narrow it.

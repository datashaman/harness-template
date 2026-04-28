# The harness

The set of guides and sensors that keep this codebase legible to both humans and agents. Three layers, ordered by cost.

## 1. Feedforward (free, runs in your head)

- [`AGENTS.md`](../AGENTS.md) — the golden principles. Read this first.
- [`docs/architecture.md`](architecture.md) — module boundaries, namespace mapping, the four-layer model in Laravel.
- [`docs/conventions.md`](conventions.md) — naming, errors, logging, Eloquent, HTTP, PHP idioms.
- [`harness/policies/`](../harness/policies/) — opinionated semgrep rules (one per file, one-line rationale on each).

## 2. Computational sensors (milliseconds–seconds)

Run on every change. If any fail, the PR doesn't land. Run all locally with:

```bash
./scripts/harness-check.sh
```

| Sensor       | What it checks                                                       | Tool                                                                         |
|--------------|----------------------------------------------------------------------|------------------------------------------------------------------------------|
| Format       | Applies code style fixes (Pint applies; Prettier --write if installed) | `./vendor/bin/pint` + `prettier --write`                                     |
| Lint         | Verifies style + lint rules (Pint --test; ESLint if installed)       | `./vendor/bin/pint --test` + `eslint`                                        |
| Typecheck    | PHP type correctness (level 8); TypeScript if `tsconfig.json` present | `./vendor/bin/phpstan analyse` + `tsc --noEmit`                              |
| Test         | Behaviour + coverage (`--min=70` when pcov/xdebug loaded)            | `./vendor/bin/pest`                                                          |
| Architecture | Layer-boundary invariants from `docs/architecture.md`                | Pest Arch in `checks/ArchitectureTest.php`                                   |
| Deadcode     | Unused symbols, missing return types, outdated patterns              | `./vendor/bin/rector process --dry-run`                                      |
| Audit        | Known CVEs in PHP deps; npm deps if `package-lock.json` present      | `composer audit --no-dev` + `npm audit --omit=dev`                           |
| Policy       | Cross-cutting rules (no empty catch, no `print` in `app/`, …)        | `semgrep --config harness/policies/` (graceful no-op when not installed)     |

JS sensors (Prettier, ESLint, `tsc`, `npm audit`) only fire when their corresponding files exist (`node_modules/.bin/<tool>`, `tsconfig.json`, `package-lock.json`). Fresh `composer create-project laravel/laravel` ships Vite but not Prettier/ESLint — `npm i -D prettier eslint` to enable them.

**Why format applies and lint checks:** the convention is `pint` rewrites files in place, `pint --test` exits non-zero on drift. Running them in that order means `harness-check.sh` auto-fixes what it can (format) and only fails on the things Pint couldn't auto-fix (lint, typecheck, tests). If `format` mutated files during the run, your working tree will show changes — stage and commit them.

The `test` sensor auto-detects whether `pcov` or `xdebug` is loaded; with neither, it runs Pest without the coverage gate.

## 3. Inferential sensors (minutes, sampled)

Run in CI and on demand. Slower, smarter, occasionally wrong — treat their output as input to your judgment, not as a gate.

- **Claude Code review** — `/review` locally, `.github/workflows/review.yml` in CI.
- **Codex review** — `codex review`, same workflow.
- **Disagreements:** deterministic sensors win. If both inferential reviewers flag the same thing, take it seriously.

## 4. Spec-to-PR factory

`.github/workflows/issue-implement.yml` fires on issues labeled `agent:implement`. It boots the toolchain, creates `agent/issue-<n>`, runs Claude Code with the issue body + `AGENTS.md` + `docs/architecture.md` as context, lets the agent iterate `harness-check.sh` until green, commits, and opens a PR.

Setup is documented in [`README.md`](../README.md#one-time-setup).

## 5. Garbage collection (nightly, in the background)

`scripts/gc-refactor.sh` runs on a schedule (`.github/workflows/gc.yml`). It:

1. Re-scores every file in `app/` against `harness/grades.yml`.
2. Picks the lowest-graded files that have a clear, mechanical fix.
3. Opens a small refactor PR per fix, with the failing grade in the description.

These PRs should be reviewable in under a minute. If they aren't, the GC step is too ambitious — narrow it.

## Extending the harness

When a class of bug bites you twice, add a rule to `harness/policies/` (one rule per file, one-line rationale). When a grade matters more than the others, edit `harness/grades.yml`. When a layer-boundary invariant changes, update `checks/ArchitectureTest.php` and `docs/architecture.md` in the same PR.

The harness is code. Agents are expected to extend it via the same PR flow as everything else.

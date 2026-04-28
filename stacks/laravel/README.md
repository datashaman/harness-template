# Laravel project — bootstrapped from [harness-template](https://github.com/datashaman/harness-template)

Built around the harness-engineering principles described by [OpenAI](https://openai.com/index/harness-engineering/) and [Martin Fowler](https://martinfowler.com/articles/harness-engineering.html). Every change is gated by fast computational sensors locally and a slower inferential review (Claude + Codex) on the PR; an issue-driven workflow can implement specifications end-to-end and open a PR for human review.

## Layout

```
app/
├── Domain/             pure PHP, no Illuminate imports — rules, value objects, entities
├── UseCases/           one verb per class; composes Domain + Infrastructure into intents
├── Infrastructure/     ports + adapters (Clock, repositories, external SDK wrappers)
├── Http/               controllers, middleware, requests, resources
└── Console/            Artisan commands

# When you `composer create-project laravel/laravel .` on top, Laravel adds:
#   app/Models, app/Providers, app/Jobs, app/Mail, app/Notifications,
#   app/Events, app/Listeners, app/Casts  — all part of the Infrastructure layer.

tests/
├── Unit/               mirrors app/ — domain + use-case tests
├── Feature/            HTTP / integration flows
└── Browser/            Pest browser plugin

checks/
└── ArchitectureTest.php   Pest\Arch invariants — fails the build on boundary violations

harness/
├── grades.yml          quality grades the GC loop tracks
└── policies/           opinionated semgrep rules

scripts/
├── harness-check.sh    run every sensor in cheapest-first order
├── gc-refactor.sh      nightly mechanical refactor agent
└── setup-github-labels.sh   one-time label bootstrap (agent:implement, agent:generated)
```

## The four-layer model

| Layer | Namespaces | Imports allowed from |
|---|---|---|
| Domain | `App\Domain` | (nothing — pure) |
| UseCases | `App\UseCases` | Domain, Infrastructure |
| Infrastructure | `App\Infrastructure`, `App\Models`, `App\Providers`, `App\Jobs`, `App\Mail`, `App\Notifications`, `App\Events`, `App\Listeners`, `App\Casts` | Domain |
| Interface | `App\Http`, `App\Console` | UseCases (not Infrastructure directly) |

Enforced by `checks/ArchitectureTest.php` — see [AGENTS.md](AGENTS.md) for the golden principles every change must respect.

## Sensors

Run all of them locally with one command:

```bash
./scripts/harness-check.sh
```

| Sensor | Tool | Runs in |
|---|---|---|
| Format | Pint (Laravel preset + strict_types + ordered imports) | seconds |
| Lint | Pint --test | seconds |
| Typecheck | PHPStan level 8 | seconds |
| Test | Pest (with coverage when pcov/xdebug loaded; `--min=70` gate) | seconds |
| Architecture | Pest\Arch in `checks/` | seconds |
| Deadcode | Rector --dry-run (DEAD_CODE + CODE_QUALITY + TYPE_DECLARATION) | seconds |
| Audit | `composer audit --no-dev` | seconds |
| Policy | Semgrep against `harness/policies/` (graceful no-op when not installed) | seconds |

Every sensor has a reason. If one is wrong, amend the rule in the same PR — don't suppress.

## Spec-to-PR factory

File a GitHub issue using the **Implementation spec** template. The `agent:implement` label is auto-applied; `.github/workflows/issue-implement.yml` then:

1. Boots PHP 8.4 + composer + semgrep on a fresh runner.
2. Creates `agent/issue-<n>` branch.
3. Runs Claude Code with `AGENTS.md`, `docs/` (if present), and the issue body as context.
4. The agent iterates: plan → write code + tests → `./scripts/harness-check.sh` → fix → repeat (capped at 8 rounds).
5. When the harness is green, commits and pushes; opens a PR labeled `agent:generated`.
6. `harness.yml` re-runs sensors on the PR; `review.yml` runs Claude + Codex review against `AGENTS.md`.
7. A human merges (or doesn't). Auto-merge is intentionally not enabled.

If the harness can't go green or the spec is ambiguous, the agent comments on the issue with what blocked instead of pushing a half-finished PR.

## One-time setup

1. **Labels** — GitHub doesn't copy labels from template repos:
   ```bash
   ./scripts/setup-github-labels.sh
   ```

2. **Secrets** at `Settings → Secrets and variables → Actions`:
   - `ANTHROPIC_API_KEY` — for `claude-code-action` (agent runs) and `review.yml`.
   - `BOT_TOKEN` — a fine-grained PAT scoped to this repo with **Contents**, **Pull requests**, and **Issues** all set to read+write. Without this, PRs the bot opens won't trigger `harness.yml` or `review.yml` (GitHub deliberately suppresses workflow runs caused by `GITHUB_TOKEN` to prevent recursion).
   - `OPENAI_API_KEY` — optional; only needed if you want Codex review alongside Claude in `review.yml`.

3. **Repo settings** at `Settings → Actions → General → Workflow permissions`:
   - Select **Read and write permissions**.
   - Check **Allow GitHub Actions to create and approve pull requests**.

## Day-to-day in Claude Code

- `/harness-check` — run all sensors, fix until green.
- `/grade <file>` — print the quality grades for one file.
- `/gc-refactor <grade> <file>` — apply one mechanical fix in a small PR.
- The `PostToolUse` hook in `.claude/settings.json` runs the harness after every Edit/Write and dumps to `/tmp/harness-last.log`, so the agent sees the consequence of its last edit before its next one.

## Domain vs Models

`App\Domain` holds the *rules*. `App\Models` holds the *rows*. The architecture invariant says Domain can't import Illuminate — so when you have non-trivial business rules, separate them into a domain entity with an Eloquent record + mapper repository. When the rules are trivial, leave Domain holding only value objects and put behavior on the Eloquent class. Both are valid; the harness only enforces direction (dependencies point inward).

## Philosophy

1. **Small surface, sharp edges.** Every check exists because skipping it has bitten someone.
2. **Computational before inferential.** Linters and types in milliseconds; agent review in minutes; never the other way.
3. **The harness is code.** It lives in the repo, has tests, and agents are expected to extend it.

The full version is in [AGENTS.md](AGENTS.md), [docs/architecture.md](docs/architecture.md), and [docs/conventions.md](docs/conventions.md) if those are present.

# harness-template

A polyglot starting point for building software *with* coding agents (Claude Code, Codex, and friends) instead of around them. Embodies the harness-engineering principles described by [OpenAI](https://openai.com/index/harness-engineering/) and [Martin Fowler](https://martinfowler.com/articles/harness-engineering.html):

- **Feedforward guides** — agent-readable docs that steer behavior *before* it acts.
- **Feedback sensors** — fast deterministic checks plus slower inferential reviews that catch drift *after* it acts.
- **Garbage collection** — scheduled background agents that open small, automergeable refactor PRs against quality grades.

## Layout

```
.
├── AGENTS.md              # golden principles (read by every agent)
├── CLAUDE.md              # Claude-Code-flavored mirror of AGENTS.md
├── docs/
│   ├── architecture.md    # module boundaries & invariants
│   ├── conventions.md     # coding conventions, naming, error handling
│   └── harness.md         # how the harness itself works
├── harness/
│   ├── policies/          # opinionated rules (semgrep, custom linters)
│   └── grades.yml         # quality grades the GC loop tracks
├── stacks/
│   ├── typescript/        # drop-in profile (tsc, eslint, vitest, knip)
│   ├── python/            # drop-in profile (ruff, mypy, pytest, vulture)
│   ├── go/                # drop-in profile (go vet, staticcheck, golangci-lint)
│   └── laravel/           # drop-in profile (pint, phpstan, pest+arch, rector)
├── scripts/
│   ├── install-stack.sh   # picks one stacks/* profile and wires it in
│   ├── harness-check.sh   # run all sensors locally
│   └── gc-refactor.sh     # entry point for the scheduled refactor agent
├── .github/workflows/
│   ├── harness.yml        # computational sensors on every PR
│   ├── review.yml         # inferential review (Claude / Codex) on PRs
│   └── gc.yml             # nightly garbage collection / drift detection
└── .claude/
    ├── commands/          # /harness-check, /gc-refactor, /grade
    └── settings.json      # hooks, permissions
```

## Quickstart

```bash
./scripts/install-stack.sh typescript    # or python, go, laravel
./scripts/harness-check.sh               # run sensors locally
```

## Spec-to-PR factory (optional)

File a GitHub issue using the `Implementation spec` template (`.github/ISSUE_TEMPLATE/spec.yml`). The `agent:implement` label fires `.github/workflows/issue-implement.yml`, which:

1. Sets up the stack toolchain (mirrors `harness.yml`).
2. Creates a branch `agent/issue-<n>` and runs Claude Code with the issue body, `AGENTS.md`, and `docs/architecture.md` as context.
3. Lets the agent write code, run `./scripts/harness-check.sh` until green (up to 8 rounds), and commit.
4. Pushes the branch and opens a PR linked to the issue. `review.yml` then runs Claude + Codex review on the PR.

If the harness can't go green or the spec is ambiguous, the agent comments on the issue with what blocked instead of pushing a half-finished PR.

**One-time setup per repo:**

1. **Labels** — GitHub doesn't copy labels from template repos:
   ```bash
   ./scripts/setup-github-labels.sh
   ```
   Creates `agent:implement` (issue trigger) and `agent:generated` (bot-opened PRs).

2. **Secrets** — at `https://github.com/<owner>/<repo>/settings/secrets/actions`:
   - `ANTHROPIC_API_KEY` — for `claude-code-action` (agent runs) and `review.yml`.
   - `BOT_TOKEN` — a fine-grained PAT scoped to this repo with **Contents: read+write**, **Pull requests: read+write**, **Issues: read+write**. Without this, `harness.yml` and `review.yml` won't fire on PRs the bot opens — GitHub deliberately suppresses workflow runs caused by `GITHUB_TOKEN` to prevent recursion. The PAT-driven push triggers them.

3. **Repo settings** — at `https://github.com/<owner>/<repo>/settings/actions`, in **Workflow permissions**:
   - Select **Read and write permissions**.
   - Check **Allow GitHub Actions to create and approve pull requests**.

Auto-merge is intentionally not enabled. The harness gates correctness; you decide intent.

## Philosophy

1. **Small surface, sharp edges.** Every check exists because skipping it has bitten someone. No sensor without a reason on its line.
2. **Computational before inferential.** Linters and types in milliseconds; agent review in minutes; never the other way around.
3. **The harness is code.** It lives in the repo, it has tests, and agents are expected to extend it.

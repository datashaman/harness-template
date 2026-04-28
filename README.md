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
│   └── go/                # drop-in profile (go vet, staticcheck, golangci-lint)
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
./scripts/install-stack.sh typescript    # or python, or go
./scripts/harness-check.sh               # run sensors locally
```

## Philosophy

1. **Small surface, sharp edges.** Every check exists because skipping it has bitten someone. No sensor without a reason on its line.
2. **Computational before inferential.** Linters and types in milliseconds; agent review in minutes; never the other way around.
3. **The harness is code.** It lives in the repo, it has tests, and agents are expected to extend it.

# Golden principles

These rules are mechanical. Follow them without negotiation. If a rule is wrong for a specific case, change the rule in this file in the same PR — don't quietly violate it.

## Code

1. **Prefer the shared utility over a hand-rolled helper.** Search `src/` (or stack equivalent) for an existing function before writing a new one.
2. **Validate boundaries with typed SDKs.** Anything crossing a process or network boundary is parsed against a schema (zod / pydantic / encoding/json + struct tags). Internal calls trust their types.
3. **No silent fallbacks.** If a value is missing, fail loudly at the boundary. Defaults belong in config, not in the middle of the call stack.
4. **One file = one responsibility.** Splitting a file is cheap. Don't grow `utils.ts` past ~200 lines.
5. **Public API surface is intentional.** Exports are listed in an `index` barrel per module; nothing else is importable from outside the module.

## Tests

6. **Tests assert behavior, not implementation.** No mocking what you own. Mock at the boundary (HTTP, DB, clock).
7. **Every fix ships with a regression test.** The failing test must fail before the fix and pass after.
8. **Snapshots only for stable, reviewed output.** Never for IDs, timestamps, or anything you'd be tempted to bulk-update.

## Process

9. **Small PRs.** A PR does one thing. Refactors and behavior changes ship separately.
10. **The harness is authoritative.** If `./scripts/harness-check.sh` fails, the PR doesn't land — even if it "works on my machine."
11. **Edit the rule before breaking it.** If you find a golden principle in your way, propose an amendment in the PR description.

## What to do when stuck

- Read `docs/architecture.md`. Module boundaries are load-bearing here.
- Run `./scripts/harness-check.sh` and read its output before trying another fix.
- If two sensors disagree, the deterministic one (types, tests) wins over the inferential one (agent review).

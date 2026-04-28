# Conventions

## Naming

- Files: `kebab-case` for modules, `PascalCase` for types-only files.
- Functions: verbs (`fetchUser`, `parse_payload`).
- Booleans: predicate form (`isActive`, `has_token`).
- Avoid `Manager`, `Helper`, `Util` in names. They hide responsibilities.

## Errors

- Throw / return errors at the boundary where the failure is meaningful.
- Never swallow an error to "recover" silently. If you catch, log with context **and** rethrow or return an explicit error result.
- One error type per recoverable category. Don't reuse a generic `Error` for cases the caller needs to distinguish.

## Logging

- Structured logs only. No `console.log` / `print` in committed code.
- Each log line carries: `event`, `subject_id` (if applicable), `outcome`.
- Levels: `debug` for development noise, `info` for state transitions, `warn` for recoverable anomalies, `error` for failures that need a human.

## Configuration

- Read config once at startup, validate against a schema, pass the typed config object explicitly.
- No `process.env` / `os.environ` reads outside the config module.

## Tests

- File next to the code: `foo.ts` ↔ `foo.test.ts`. Same for Python (`test_foo.py` colocated where practical) and Go (`foo_test.go`).
- Arrange / Act / Assert sections separated by a blank line. Don't write a "framework" of test helpers — test code is read more than it's written.
- Use real implementations whenever practical. Fake at the network or process boundary, not at internal interfaces.

# Architecture

> Edit this file when you add or remove a module, or when a boundary changes. The harness reads it.

## Module map

```
src/
├── core/         # pure domain logic. no I/O. no framework imports.
├── adapters/     # I/O at the edges: HTTP clients, DB, queues, filesystem.
├── app/          # use cases / orchestration. wires core + adapters.
└── interface/    # entry points: HTTP routes, CLI, jobs.
```

## Invariants

- `core/` does not import from `adapters/`, `app/`, or `interface/`.
- `adapters/` does not import from `app/` or `interface/`.
- `interface/` does not import from `adapters/` directly — only via `app/`.
- Cross-cutting concerns (logging, tracing) flow through explicit context, not globals.

These invariants are enforced by the structural test in each `stacks/*/checks/architecture.*`.

## Data flow

```
interface  →  app  →  core
                ↘  adapters  ↗
```

A request enters at `interface/`, is decoded to a domain command in `app/`, executed against `core/` logic, and any side effects happen via `adapters/`. Results flow back the same way.

## Adding a module

1. Create the directory under the right layer.
2. Add a barrel `index` that lists the public surface.
3. Update this file.
4. Add an architecture-fitness assertion if the module introduces a new boundary.

# Conventions

## Naming

- **Classes:** `PascalCase`. One class per file. Final by default; only mark non-final when subclassing is part of the design.
- **Methods / functions:** `camelCase`. Verbs (`fetchUser`, `publishPost`).
- **Properties:** `camelCase`. Predicate form for booleans (`isActive`, `hasToken`).
- **Constants:** `UPPER_SNAKE_CASE`.
- **Files:** match the class name (`SayHello.php`).
- **Namespaces:** match the directory under `app/`. Don't fight PSR-4.
- **Routes:** `kebab-case` segments, plural collections (`/posts`, `/posts/{post}/comments`).
- **DB tables:** `snake_case`, plural. Columns: `snake_case`, singular.
- **Avoid `Manager`, `Helper`, `Util`, `Service`** in names. They hide responsibility. Prefer the verb (`SendInvoice` not `InvoiceService`).

## Errors

- **One exception type per recoverable category.** Custom exceptions in `App\Domain\Exceptions\*` for domain errors (`PostAlreadyPublished`); reuse `InvalidArgumentException` only for cheap precondition checks.
- **Throw at the boundary.** Validation failures throw at the use case entry; persistence failures bubble from the repository.
- **Never catch and swallow.** If you catch, log with context and rethrow, or convert to a typed result. The semgrep policy in `harness/policies/` flags empty `catch` blocks as errors.
- **No silent defaults in the call stack.** Defaults live in config or in constructor parameters, not in the middle of a method.

## Logging

- **Use the structured logger.** `Log::info('event_name', ['key' => $value])` — never plain string interpolation, never `dump()` / `dd()` / `var_dump()`.
- **No `print` / `echo` in committed code.** Pint's `no_unused_imports` won't catch this; semgrep's `print-in-src` rule (when enabled) does.
- **Each log line carries:** `event` (snake_case verb), `subject_id` (when applicable), `outcome` (`ok` / `failed` / `skipped`).
- **Levels:**
  - `debug` — developer noise, off in production.
  - `info` — state transitions worth knowing about (`post.published`, `user.registered`).
  - `warning` — recoverable anomalies (a retry succeeded, a fallback fired).
  - `error` — failures that need a human to look at.
  - `critical` — pageable.

## Configuration

- **Read config once at boot.** `config('foo.bar')` belongs in service providers and use case constructors, not deep in domain code.
- **Validate config at boot.** A typed `App\Infrastructure\Config\<Foo>Config` class instantiated from `config(...)` in a service provider is preferable to passing `array` everywhere.
- **No `env()` outside config files.** Laravel caches `config:cache` in production and `env()` returns null when the config cache is built. The `[NoEnvOutsideConfig]` rule (when enabled in PHPStan or semgrep) catches this.

## Tests

- **Pest by default.** `it('does the thing', ...)` / `test('...', ...)`. Pest's expectation API is the assertion DSL.
- **Mirror the source tree.** `app/UseCases/PublishPost.php` ↔ `tests/Unit/UseCases/PublishPostTest.php`.
- **Three test groups:**
  - `tests/Unit/` — pure logic, no DB, no HTTP. Domain + use case tests with infrastructure faked at the port.
  - `tests/Feature/` — boots the framework. HTTP routes, jobs running through the queue, mail being captured. Use Laravel's `Mail::fake()`, `Queue::fake()`, etc.
  - `tests/Browser/` — Pest browser plugin. End-to-end flows in a real browser.
- **Arrange / Act / Assert** sections separated by a blank line. Don't extract test helpers until the third repetition.
- **Real implementations whenever practical.** Fake at the network or process boundary (HTTP client, queue connection, mail transport, clock). Don't fake what you own.
- **Every fix ships with a regression test.** The failing test must fail before the fix and pass after.

## Eloquent

- **Models live in `App\Models`.** They're Infrastructure (per `docs/architecture.md`). Don't import `App\Models\*` from `App\Domain` or `App\Http` — go through use cases.
- **Don't put domain rules on Eloquent models** unless you've explicitly chosen the "light domain" pattern in `docs/architecture.md`. If you have, document it in the model's docblock so the next person knows the model is doing double duty.
- **Scopes** for read-side query helpers are fine on the model; **mutations** belong in use cases or domain entities.
- **`$fillable` over `$guarded = []`.** Be explicit about what's mass-assignable.
- **Casts** for value-object boundaries (`'metadata' => Metadata::class`) — keep the model thin and the cast smart.

## HTTP

- **Form Requests** for input validation. Don't validate inside controllers.
- **Controllers are thin.** Three lines max: parse the request → call the use case → return a response.
- **Resource classes** for output shaping. No raw model serialization in JSON responses.
- **No business logic in middleware.** Middleware is for cross-cutting concerns (auth, throttling, tracing) — anything domain-shaped goes in a use case.

## PHP-specific

- **`declare(strict_types=1);`** at the top of every PHP file. Pint's preset adds it; the architecture test asserts it via `arch('strict types declared in every file')`.
- **`final readonly class`** for value objects and use cases. Mutable state is a smell; require it consciously.
- **Constructor promotion** (`public function __construct(private readonly Foo $foo) {}`) for dependencies.
- **Return types are mandatory.** Including `: void`. Pint catches missing ones; PHPStan level 8 catches inferable mismatches.
- **No magic.** Avoid `__call`, `__get`, `__set`, dynamic property access in committed code unless you have a written reason.

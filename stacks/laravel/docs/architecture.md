# Architecture

> Edit this file when you add or remove a module, or when a boundary changes. The harness reads it.

## Module map

```
app/
├── Domain/             pure PHP, no Illuminate imports — rules, value objects, entities
├── UseCases/           one verb per class; composes Domain + Infrastructure into intents
├── Infrastructure/     custom ports + adapters (Clock, repositories, external SDK wrappers)
├── Http/               controllers, middleware, requests, resources
└── Console/            Artisan commands

# Laravel's default namespaces (created by `composer create-project laravel/laravel .`
# and by `php artisan make:*`) all map into the Infrastructure layer:
#   app/Models, app/Providers, app/Jobs, app/Mail, app/Notifications,
#   app/Events, app/Listeners, app/Casts
```

## Layer map

| Layer          | Namespaces                                                                                                                               | Imports allowed from         |
|----------------|------------------------------------------------------------------------------------------------------------------------------------------|------------------------------|
| Domain         | `App\Domain`                                                                                                                             | (nothing — pure PHP only)    |
| UseCases       | `App\UseCases`                                                                                                                           | Domain, Infrastructure       |
| Infrastructure | `App\Infrastructure`, `App\Models`, `App\Providers`, `App\Jobs`, `App\Mail`, `App\Notifications`, `App\Events`, `App\Listeners`, `App\Casts` | Domain                       |
| Interface      | `App\Http`, `App\Console`                                                                                                                | UseCases (not Infrastructure) |

## Invariants

- **Domain is pure.** `App\Domain\*` does not import `Illuminate\*`, `Symfony\*`, `App\UseCases\*`, `App\Infrastructure\*`, `App\Models\*`, `App\Http\*`, or `App\Console\*`. Domain code is testable in milliseconds without booting the framework.
- **Infrastructure depends on Domain only.** Eloquent models, jobs, mail, providers, custom adapters can import `App\Domain` and each other. They cannot import `App\UseCases`, `App\Http`, or `App\Console`.
- **Interface goes through UseCases.** Controllers and Artisan commands inject use cases. They never import Eloquent models, jobs, or other infrastructure directly. If a controller needs DB access, the use case is the seam.
- **No silent fallbacks.** Errors are typed; defaults live in config, not in the middle of the call stack.

These invariants are enforced by the Pest Arch tests in `checks/ArchitectureTest.php` — boundary violations fail the build.

## Data flow

```
HTTP request / Artisan invocation
        │
        ▼
   App\Http  /  App\Console      ← parses input, calls a use case
        │
        ▼
   App\UseCases                  ← composes domain rules with infrastructure
        │            │
        ▼            ▼
   App\Domain    App\Models / App\Infrastructure / …
   (pure)         (I/O)
```

A request enters at `App\Http` or `App\Console`, is decoded into a typed call against an `App\UseCases\*` class, which executes domain rules from `App\Domain` and persists / dispatches via the Infrastructure layer. Results flow back the same way.

## Domain vs Models

`App\Domain` holds the rules; `App\Models` holds the rows. The architecture invariant forces a choice:

- **Light domain:** keep `App\Domain` to value objects only (Money, EmailAddress, PostId). Put entity behavior on `App\Models\Post extends Model`. Use cases call Eloquent directly. Tests need a DB or sqlite.
- **Full domain:** model entities in `App\Domain\Post` (pure PHP), persistence in `App\Models\PostRecord extends Model`, mapping in `App\Infrastructure\Persistence\Eloquent\EloquentPostRepository`. Use cases inject the repository. Tests run without a DB.

Both pass the architecture test. Pick based on how complex your invariants are — start light, promote to full only when an entity has rules worth isolating.

## Adding a module

1. Pick the layer. If you're not sure: pure logic → `App\Domain`; orchestration / transactions → `App\UseCases`; talks to the outside world → Infrastructure (`App\Models` for ORM, `App\Infrastructure\<Service>` for external APIs); HTTP → `App\Http`; CLI → `App\Console`.
2. Create the directory + namespace. Run `composer dump-autoload` if needed.
3. Add tests under the mirrored `tests/Unit/<Layer>/` path.
4. Update this file if you've introduced a new top-level namespace under `App\`.
5. If the namespace is a new layer (rare), update `checks/ArchitectureTest.php` to map it.

## Cross-cutting concerns

- **Logging:** use `Illuminate\Support\Facades\Log` from infrastructure / interface layers. Domain code returns rich data; the use case decides what to log.
- **Time:** inject `App\Infrastructure\Clock`. Don't call `now()`, `Carbon::now()`, or `time()` from `App\Domain` or `App\UseCases` — use the Clock port. Tests pass a fake.
- **Randomness:** same — inject a port for anything non-deterministic.
- **Config:** read once at boot via `config(...)`, pass typed values into use cases. Don't reach for `config()` mid-call-stack.

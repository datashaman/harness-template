<?php

declare(strict_types=1);

// Structural fitness test. Fails if module-boundary invariants from
// docs/architecture.md are violated. Runs as part of `pest`.
//
// Layer map:
//   Domain          → App\Domain
//   UseCases        → App\UseCases  (the "Application" layer in clean-arch)
//   Infrastructure  → App\Infrastructure, App\Models, App\Providers, App\Jobs,
//                     App\Mail, App\Notifications, App\Events, App\Listeners,
//                     App\Casts
//   Interface       → App\Http, App\Console

arch('domain has no I/O dependencies')
    ->expect('App\Domain')
    ->not->toUse([
        'App\UseCases',
        'App\Infrastructure',
        'App\Models',
        'App\Providers',
        'App\Jobs',
        'App\Mail',
        'App\Notifications',
        'App\Events',
        'App\Listeners',
        'App\Casts',
        'App\Http',
        'App\Console',
        'Illuminate',          // no Laravel imports in pure domain
        'Symfony',
    ]);

arch('infrastructure does not depend on use cases or interface')
    ->expect([
        'App\Infrastructure',
        'App\Models',
        'App\Providers',
        'App\Jobs',
        'App\Mail',
        'App\Notifications',
        'App\Events',
        'App\Listeners',
        'App\Casts',
    ])
    ->not->toUse(['App\UseCases', 'App\Http', 'App\Console']);

arch('interface does not import infrastructure directly')
    ->expect(['App\Http', 'App\Console'])
    ->not->toUse([
        'App\Infrastructure',
        'App\Models',
        'App\Jobs',
        'App\Mail',
        'App\Notifications',
        'App\Events',
        'App\Listeners',
        'App\Casts',
    ]);

arch('strict types declared in every file')
    ->expect('App')
    ->toUseStrictTypes();

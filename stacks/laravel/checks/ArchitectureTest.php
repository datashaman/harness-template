<?php

declare(strict_types=1);

// Structural fitness test. Fails if module-boundary invariants from
// docs/architecture.md are violated. Runs as part of `pest`.

arch('domain has no I/O dependencies')
    ->expect('App\Domain')
    ->not->toUse([
        'App\Application',
        'App\Infrastructure',
        'App\Http',
        'Illuminate',          // no Laravel imports in pure domain
        'Symfony',
    ]);

arch('infrastructure does not depend on application or http')
    ->expect('App\Infrastructure')
    ->not->toUse(['App\Application', 'App\Http']);

arch('http does not import infrastructure directly')
    ->expect('App\Http')
    ->not->toUse('App\Infrastructure');

arch('strict types declared in every file')
    ->expect('App')
    ->toUseStrictTypes();

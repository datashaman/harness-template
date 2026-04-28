<?php

declare(strict_types=1);

use App\Domain\Greeting;

it('greets a name', function (): void {
    expect(Greeting::for('Ada'))->toBe('Hello, Ada.');
});

it('rejects an empty name', function (): void {
    expect(fn (): string => Greeting::for(''))->toThrow(InvalidArgumentException::class, 'name is required');
});

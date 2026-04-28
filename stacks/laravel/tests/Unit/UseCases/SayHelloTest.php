<?php

declare(strict_types=1);

use App\Infrastructure\Clock;
use App\UseCases\SayHello;

beforeEach(function (): void {
    $this->fixedClock = new class implements Clock
    {
        public function now(): DateTimeImmutable
        {
            return new DateTimeImmutable('2026-04-28T12:00:00+00:00');
        }
    };
});

it('prefixes the greeting with the clock timestamp', function (): void {
    $sayHello = new SayHello($this->fixedClock);
    expect($sayHello('Ada'))->toBe('[2026-04-28T12:00:00+00:00] Hello, Ada.');
});

it('propagates name validation from the domain', function (): void {
    $sayHello = new SayHello($this->fixedClock);
    expect(fn (): string => $sayHello(''))->toThrow(InvalidArgumentException::class, 'name is required');
});

<?php

declare(strict_types=1);

namespace App\UseCases;

use App\Domain\Greeting;
use App\Infrastructure\Clock;
use App\Infrastructure\SystemClock;

final readonly class SayHello
{
    public function __construct(private Clock $clock = new SystemClock) {}

    public function __invoke(string $name): string
    {
        return sprintf('[%s] %s', $this->clock->now()->format('c'), Greeting::for($name));
    }
}

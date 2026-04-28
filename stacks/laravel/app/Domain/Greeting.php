<?php

declare(strict_types=1);

namespace App\Domain;

use InvalidArgumentException;

final class Greeting
{
    public static function for(string $name): string
    {
        if ($name === '') {
            throw new InvalidArgumentException('name is required');
        }

        return "Hello, {$name}.";
    }
}

<?php

declare(strict_types=1);

namespace App\Http;

use App\Application\SayHello;
use Illuminate\Console\Command;

final class HelloCommand extends Command
{
    protected $signature = 'app:hello {name=world}';

    protected $description = 'Print a timestamped greeting.';

    public function handle(SayHello $sayHello): int
    {
        /** @var string $name */
        $name = $this->argument('name');
        $this->line($sayHello($name));

        return self::SUCCESS;
    }
}

import { type Clock, systemClock } from "@adapters/index.js";
import { greet } from "@core/index.js";

export function sayHello(name: string, clock: Clock = systemClock): string {
  return `[${clock.now().toISOString()}] ${greet(name)}`;
}

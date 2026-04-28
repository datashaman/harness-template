import { greet } from "@core/index.js";
import type { Clock } from "@adapters/index.js";

export function sayHello(clock: Clock, name: string): string {
  return `[${clock.now().toISOString()}] ${greet(name)}`;
}

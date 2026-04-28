import { sayHello } from "@app/index.js";
import { systemClock } from "@adapters/index.js";

const name = process.argv[2] ?? "world";
console.warn(sayHello(systemClock, name));

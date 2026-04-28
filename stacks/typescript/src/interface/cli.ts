import { sayHello } from "@app/index.js";

const name = process.argv[2] ?? "world";
console.warn(sayHello(name));

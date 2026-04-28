import { describe, expect, it } from "vitest";
import { sayHello } from "./say-hello.js";
import type { Clock } from "@adapters/index.js";

const fixedClock: Clock = { now: () => new Date("2026-04-28T12:00:00Z") };

describe("sayHello", () => {
  it("prefixes the greeting with the clock timestamp", () => {
    expect(sayHello("Ada", fixedClock)).toBe("[2026-04-28T12:00:00.000Z] Hello, Ada.");
  });

  it("propagates name validation from core", () => {
    expect(() => sayHello("", fixedClock)).toThrow("name is required");
  });
});

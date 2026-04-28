/**
 * Structural fitness test. Fails if module-boundary invariants from
 * docs/architecture.md are violated. Run as part of `npm test`.
 */
import { describe, expect, it } from "vitest";
import { readFileSync } from "node:fs";
import { globSync } from "node:fs";
import { join } from "node:path";

type Layer = "core" | "adapters" | "app" | "interface";

const allowed: Record<Layer, Layer[]> = {
  core: ["core"],
  adapters: ["core", "adapters"],
  app: ["core", "adapters", "app"],
  interface: ["app", "interface"],
};

function layerOf(path: string): Layer | null {
  const m = path.match(/src\/(core|adapters|app|interface)\//);
  return (m?.[1] as Layer) ?? null;
}

describe("architecture invariants", () => {
  const files = globSync("src/**/*.{ts,tsx}", { cwd: process.cwd() });
  for (const file of files) {
    const layer = layerOf(file);
    if (!layer) continue;
    it(`${file} only imports allowed layers`, () => {
      const src = readFileSync(join(process.cwd(), file), "utf8");
      const imports = [...src.matchAll(/from\s+["']([^"']+)["']/g)].map(
        (m) => m[1]!,
      );
      for (const spec of imports) {
        const target = spec.match(/@(core|adapters|app|interface)\b/);
        if (!target) continue;
        const t = target[1] as Layer;
        expect(
          allowed[layer].includes(t),
          `${file} (${layer}) → ${spec} (${t}) violates docs/architecture.md`,
        ).toBe(true);
      }
    });
  }
});

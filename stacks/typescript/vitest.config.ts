import { defineConfig } from "vitest/config";
import { fileURLToPath } from "node:url";

export default defineConfig({
  resolve: {
    alias: {
      "@core": fileURLToPath(new URL("./src/core", import.meta.url)),
      "@adapters": fileURLToPath(new URL("./src/adapters", import.meta.url)),
      "@app": fileURLToPath(new URL("./src/app", import.meta.url)),
      "@interface": fileURLToPath(new URL("./src/interface", import.meta.url)),
    },
  },
  test: {
    coverage: {
      provider: "v8",
      include: ["src/**/*.ts"],
      exclude: [
        "**/*.test.ts",
        "src/**/index.ts",
        "src/interface/**", // entry points — exercised by integration tests, not unit
        "src/adapters/**", // adapters wrap I/O — exercised via fakes in app tests
      ],
      thresholds: { lines: 70, functions: 70, branches: 70, statements: 70 },
    },
  },
});

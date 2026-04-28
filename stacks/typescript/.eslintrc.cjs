/* eslint-env node */
module.exports = {
  root: true,
  parser: "@typescript-eslint/parser",
  parserOptions: { project: "./tsconfig.json" },
  plugins: ["@typescript-eslint", "boundaries"],
  extends: [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended-type-checked",
    "plugin:boundaries/recommended",
  ],
  settings: {
    "boundaries/elements": [
      { type: "core", pattern: "src/core/*" },
      { type: "adapters", pattern: "src/adapters/*" },
      { type: "app", pattern: "src/app/*" },
      { type: "interface", pattern: "src/interface/*" },
    ],
  },
  rules: {
    "boundaries/element-types": [
      "error",
      {
        default: "disallow",
        rules: [
          { from: "core", allow: ["core"] },
          { from: "adapters", allow: ["core", "adapters"] },
          { from: "app", allow: ["core", "adapters", "app"] },
          { from: "interface", allow: ["app", "interface"] },
        ],
      },
    ],
    "@typescript-eslint/no-floating-promises": "error",
    "@typescript-eslint/no-unused-vars": ["error", { argsIgnorePattern: "^_" }],
    "no-console": ["error", { allow: ["warn", "error"] }],
  },
  ignorePatterns: ["dist/", "node_modules/", "**/*.generated.*"],
};

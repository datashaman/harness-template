export function greet(name: string): string {
  if (!name) throw new Error("name is required");
  return `Hello, ${name}.`;
}

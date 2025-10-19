import { describe, it, expect } from "vitest";
import { calculateTotal } from "./calculateTotal";

// This is a unit test for the calculateTotal function written with vitest
describe("calculateTotal", () => {
  it("sums valid numbers", () => {
    expect(calculateTotal("100,200,300")).toBe(600);
  });

  it("handles whitespace", () => {
    expect(calculateTotal("100, 200, 300")).toBe(600);
  });

  it("handles empty string", () => {
    expect(calculateTotal("")).toBe(0);
  });

  it("handles invalid inputs", () => {
    expect(calculateTotal("abc,100,def")).toBe(0);
  });

  it("handles trailing comma", () => {
    expect(calculateTotal("100,200,")).toBe(300);
  });

  it("handles new lines", () => {
    expect(calculateTotal("100\n,200\n,300")).toBe(600);
  });
});

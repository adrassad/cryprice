import { strictEqual, doesNotThrow } from "node:assert";
import { test } from "node:test";
import { normalizeAdapterHealthFactor } from "../../src/services/healthfactor/healthfactor.normalize.js";

test("null / undefined health factor → skip persist", () => {
  const a = normalizeAdapterHealthFactor(null);
  strictEqual(a.healthfactor, null);
  strictEqual(a.skip, true);

  const b = normalizeAdapterHealthFactor(undefined);
  strictEqual(b.healthfactor, null);
  strictEqual(b.skip, true);
});

test("Infinity → no toFixed path (stored as Infinity)", () => {
  const r = normalizeAdapterHealthFactor(Infinity);
  strictEqual(r.healthfactor, Infinity);
  strictEqual(r.skip, false);
});

test("finite values rounded to 2 decimals deterministically", () => {
  const r = normalizeAdapterHealthFactor(1.234567);
  strictEqual(r.healthfactor, 1.23);
  strictEqual(r.skip, false);
});

test("NaN → null, skip (defensive)", () => {
  const r = normalizeAdapterHealthFactor(NaN);
  strictEqual(r.healthfactor, null);
  strictEqual(r.skip, true);
});

test("normalizing Infinity does not throw (regression vs RangeError on toFixed)", () => {
  doesNotThrow(() => normalizeAdapterHealthFactor(Infinity));
});

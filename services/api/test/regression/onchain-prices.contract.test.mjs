/**
 * Pure contract checks for on-chain multi-network response (no DB / HTTP).
 * Mirrors: 404 iff no network has a non-null price.
 */
import { strictEqual } from "node:assert";
import { test } from "node:test";

function should404(priceByNetwork) {
  return !Object.values(priceByNetwork).some((p) => p != null);
}

test("404 when all networks null (no price anywhere)", () => {
  strictEqual(should404({ ethereum: null, arbitrum: null }), true);
});

test("200 path when at least one network has a price", () => {
  strictEqual(should404({ ethereum: null, arbitrum: { price_usd: 1 } }), false);
});

test("404 when result object is empty", () => {
  strictEqual(should404({}), true);
});

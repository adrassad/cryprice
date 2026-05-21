import { strictEqual, ok, notStrictEqual } from "node:assert";
import { test } from "node:test";

import {
  DEFAULT_ICON_SIZE,
  deriveBackgroundColor,
  deriveSymbolInitials,
  generateErc20PlaceholderIcon,
  generateNativePlaceholderIcon,
  generatePlaceholderIconPng,
  isPngBuffer,
} from "../../src/services/asset/tokenIconGenerator.service.js";

test("deriveSymbolInitials sanitizes and limits to 3 uppercase chars", () => {
  strictEqual(deriveSymbolInitials("weth"), "WET");
  strictEqual(deriveSymbolInitials("USDC"), "USD");
  strictEqual(deriveSymbolInitials("A"), "A");
  strictEqual(deriveSymbolInitials("$"), "?");
  strictEqual(deriveSymbolInitials("  "), "?");
});

test("deriveBackgroundColor is deterministic for chainId + identity", () => {
  const first = deriveBackgroundColor(1, "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");
  const second = deriveBackgroundColor(1, "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");
  strictEqual(first, second);
  notStrictEqual(
    first,
    deriveBackgroundColor(42161, "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48"),
  );
});

test("generateErc20PlaceholderIcon returns deterministic PNG bytes", async () => {
  const input = {
    chainId: 1,
    address: "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
    symbol: "USDC",
    size: DEFAULT_ICON_SIZE,
  };

  const first = await generateErc20PlaceholderIcon(input);
  const second = await generateErc20PlaceholderIcon(input);

  ok(isPngBuffer(first));
  ok(first.length > 0);
  ok(first.equals(second));
});

test("generateNativePlaceholderIcon returns PNG bytes", async () => {
  const png = await generateNativePlaceholderIcon({
    chainId: 1,
    symbol: "ETH",
  });

  ok(isPngBuffer(png));
});

test("symbol change affects output while identity stays the same", async () => {
  const base = {
    chainId: 1,
    identityKey: "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
    size: DEFAULT_ICON_SIZE,
  };

  const weth = await generatePlaceholderIconPng({ ...base, symbol: "WETH" });
  const usdc = await generatePlaceholderIconPng({ ...base, symbol: "USDC" });

  ok(!weth.equals(usdc));
});

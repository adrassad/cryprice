import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { ok, strictEqual } from "node:assert";
import { test } from "node:test";

import {
  isUsdLikeCexSpotSymbol,
  normalizeOffchainTokenSymbol,
  OFFCHAIN_SOURCES,
  spotPairSymbolToBaseToken,
} from "../../src/services/price/offchainPriceNormalize.js";

const root = join(dirname(fileURLToPath(import.meta.url)), "../..");

test("init.js runs prepareOffchainSchemaBeforeInitDdl before off-chain CREATE INDEX", () => {
  const src = readFileSync(join(root, "src/db/init.js"), "utf8");
  const prep = src.indexOf("prepareOffchainSchemaBeforeInitDdl");
  const prices = src.indexOf("//PRICES TABLES");
  ok(prep > 0 && prices > 0 && prep < prices);
});

test("init.js off-chain DDL: token + pair, not asset_id", () => {
  const src = readFileSync(join(root, "src/db/init.js"), "utf8");
  const m = src.match(
    /CREATE TABLE IF NOT EXISTS offchain_prices\s*\(([\s\S]*?)\);/,
  );
  ok(m, "offchain_prices CREATE block present");
  ok(m[1].includes("token TEXT"));
  ok(m[1].includes("pair TEXT"));
  ok(!m[1].includes("asset_id"));

  const cur = src.match(
    /CREATE TABLE IF NOT EXISTS current_offchain_prices\s*\(([\s\S]*?)\);/,
  );
  ok(cur);
  ok(cur[1].includes("pair TEXT"));
  ok(!cur[1].includes("asset_id"));
});

test("normalization: base symbol, USD-like CEX filter, pair stripping", () => {
  strictEqual(normalizeOffchainTokenSymbol(" eth "), "ETH");
  strictEqual(spotPairSymbolToBaseToken("BTCUSDT"), "BTC");
  strictEqual(spotPairSymbolToBaseToken("ETHUSDC"), "ETH");
  strictEqual(isUsdLikeCexSpotSymbol("BTCUSDT"), true);
  strictEqual(isUsdLikeCexSpotSymbol("ETHBTC"), false);
});

test("OFFCHAIN_SOURCES enum values for DB CHECK", () => {
  strictEqual(OFFCHAIN_SOURCES.BINANCE, "binance");
  strictEqual(OFFCHAIN_SOURCES.BYBIT, "bybit");
  strictEqual(OFFCHAIN_SOURCES.COINGECKO, "coingecko");
});

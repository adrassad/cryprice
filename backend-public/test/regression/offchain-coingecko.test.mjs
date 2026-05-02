import { deepStrictEqual, strictEqual } from "node:assert";
import { test } from "node:test";

import { mapCoinGeckoMarketsPayloadToRows } from "../../src/services/price/offchainProviderClients.js";

test("mapCoinGeckoMarketsPayloadToRows maps /coins/markets page to off-chain rows", () => {
  const payload = [
    {
      id: "bitcoin",
      symbol: "btc",
      name: "Bitcoin",
      current_price: 75_000.5,
    },
    {
      id: "no-price",
      symbol: "xyz",
      current_price: null,
    },
  ];
  const rows = mapCoinGeckoMarketsPayloadToRows(payload);
  strictEqual(rows.length, 1);
  deepStrictEqual(rows[0], {
    pair: "bitcoin",
    token: "BTC",
    priceUsd: 75_000.5,
  });
});

test("mapCoinGeckoMarketsPayloadToRows rejects non-array", () => {
  strictEqual(mapCoinGeckoMarketsPayloadToRows(null).length, 0);
  strictEqual(mapCoinGeckoMarketsPayloadToRows({ error_code: 429 }).length, 0);
});


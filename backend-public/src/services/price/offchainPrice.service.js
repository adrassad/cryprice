import { db } from "../../db/index.js";

/**
 * Current off-chain quotes for a normalized base `symbol` (token), all `(source, pair)` rows.
 * Each `source` maps to an **array** of quotes (multiple pairs per exchange are normal).
 */
export async function getCurrentOffchainPricesByTicker(symbol) {
  const rows = await db.currentOffchainPrices.getByTicker(symbol);

  const result = {};

  for (const row of rows) {
    if (!result[row.source]) result[row.source] = [];
    result[row.source].push({
      source: row.source,
      token: row.token,
      pair: row.pair,
      price_usd: Number(row.price_usd),
      calculated_at: row.calculated_at,
      updated_at: row.updated_at,
    });
  }

  return result;
}

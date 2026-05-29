import Decimal from "decimal.js";
import { BaseRepository } from "./base.repository.js";

const ALLOWED_SOURCES = new Set(["binance", "bybit", "coingecko"]);
const CHUNK = 200;

function sourcePairKey(source, pair) {
  return `${source}:${pair}`;
}

function centsPrecisionValue(price) {
  return new Decimal(price).toDecimalPlaces(2, Decimal.ROUND_DOWN).toFixed(2);
}

export class OffchainPriceRepository extends BaseRepository {
  constructor(db) {
    super(db, "offchain_prices", "id");
  }

  assertRow(r) {
    const source = r.source;
    if (!ALLOWED_SOURCES.has(source)) {
      throw new Error(`offchain_prices: invalid source "${source}"`);
    }
    const token = String(r.token ?? "").trim().toUpperCase();
    const pair = String(r.pair ?? "").trim();
    if (!token) throw new Error("offchain_prices: token is required");
    if (!pair) throw new Error("offchain_prices: pair is required");
  }

  async create(object) {
    this.assertRow(object);
    await this.db.query(
      `
        INSERT INTO offchain_prices (
          source,
          token,
          pair,
          price_usd,
          collected_at
        )
        VALUES ($1, $2, $3, $4, $5)
      `,
      [
        object.source,
        String(object.token).trim().toUpperCase(),
        String(object.pair).trim(),
        object.price_usd,
        object.collected_at,
      ],
    );
  }

  /**
   * @param {Array<{ source, token, pair, price_usd, collected_at }>} rows
   */
  /**
   * @returns {Promise<{ inserted: number }>} `inserted` = rows actually written (excludes ON CONFLICT skips).
   */
  async insertHistoryBatch(rows) {
    if (!rows.length) return { inserted: 0 };
    let inserted = 0;
    for (let i = 0; i < rows.length; i += CHUNK) {
      const chunk = rows.slice(i, i + CHUNK).map((r) => {
        this.assertRow(r);
        return {
          source: r.source,
          token: String(r.token).trim().toUpperCase(),
          pair: String(r.pair).trim(),
          price_usd: r.price_usd,
          collected_at: r.collected_at,
        };
      });
      const latestByKey = await this.getLatestPricesBySourcePair(chunk);
      // Store historical off-chain price only when the value changes at cents precision.
      const rowsToInsert = [];
      for (const r of chunk) {
        const key = sourcePairKey(r.source, r.pair);
        const latestPrice = latestByKey.get(key);
        if (
          latestPrice !== undefined &&
          centsPrecisionValue(latestPrice) === centsPrecisionValue(r.price_usd)
        ) {
          continue;
        }
        rowsToInsert.push(r);
        latestByKey.set(key, r.price_usd);
      }
      if (!rowsToInsert.length) continue;

      const placeholders = [];
      const params = [];
      let p = 1;
      for (const r of rowsToInsert) {
        placeholders.push(
          `($${p++}, $${p++}, $${p++}, $${p++}, $${p++})`,
        );
        params.push(
          r.source,
          String(r.token).trim().toUpperCase(),
          String(r.pair).trim(),
          r.price_usd,
          r.collected_at,
        );
      }
      const { rowCount } = await this.db.query(
        `
          INSERT INTO offchain_prices (
            source, token, pair, price_usd, collected_at
          )
          VALUES ${placeholders.join(", ")}
          ON CONFLICT (source, pair, collected_at) DO NOTHING
        `,
        params,
      );
      inserted += rowCount ?? 0;
    }
    return { inserted };
  }

  async getLatestPricesBySourcePair(rows) {
    const keys = [];
    const params = [];
    const seen = new Set();
    let p = 1;

    for (const r of rows) {
      const key = sourcePairKey(r.source, r.pair);
      if (seen.has(key)) continue;
      seen.add(key);
      keys.push(`($${p++}, $${p++})`);
      params.push(r.source, r.pair);
    }

    if (!keys.length) return new Map();

    const { rows: latestRows } = await this.db.query(
      `
        WITH incoming(source, pair) AS (
          VALUES ${keys.join(", ")}
        )
        SELECT DISTINCT ON (p.source, p.pair)
          p.source,
          p.pair,
          p.price_usd
        FROM offchain_prices p
        JOIN incoming i
          ON i.source = p.source
         AND i.pair = p.pair
        ORDER BY p.source, p.pair, p.collected_at DESC, p.id DESC
      `,
      params,
    );

    return new Map(
      latestRows.map((r) => [
        sourcePairKey(r.source, r.pair),
        r.price_usd,
      ]),
    );
  }
}

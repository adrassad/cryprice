import { BaseRepository } from "./base.repository.js";

const ALLOWED_SOURCES = new Set(["binance", "bybit", "coingecko"]);
const CHUNK = 200;

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
      const chunk = rows.slice(i, i + CHUNK);
      const placeholders = [];
      const params = [];
      let p = 1;
      for (const r of chunk) {
        this.assertRow(r);
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
}

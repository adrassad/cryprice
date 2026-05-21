const ALLOWED_SOURCES = new Set(["binance", "bybit", "coingecko"]);
const CHUNK = 200;

export class CurrentOffchainPriceRepository {
  constructor(db) {
    this.db = db;
  }

  assertRow(r) {
    const source = r.source;
    if (!ALLOWED_SOURCES.has(source)) {
      throw new Error(`current_offchain_prices: invalid source "${source}"`);
    }
    const token = String(r.token ?? "").trim().toUpperCase();
    const pair = String(r.pair ?? "").trim();
    if (!token) throw new Error("current_offchain_prices: token is required");
    if (!pair) throw new Error("current_offchain_prices: pair is required");
  }

  async upsert(object) {
    this.assertRow(object);
    await this.db.query(
      `
        INSERT INTO current_offchain_prices (
          source,
          token,
          pair,
          price_usd,
          calculated_at,
          updated_at
        )
        VALUES ($1, $2, $3, $4, $5, NOW())
        ON CONFLICT (source, pair) DO UPDATE SET
          token = EXCLUDED.token,
          price_usd = EXCLUDED.price_usd,
          calculated_at = EXCLUDED.calculated_at,
          updated_at = NOW()
      `,
      [
        object.source,
        String(object.token).trim().toUpperCase(),
        String(object.pair).trim(),
        object.price_usd,
        object.calculated_at,
      ],
    );
  }

  /**
   * @param {Array<{ source, token, pair, price_usd, calculated_at }>} rows
   */
  /**
   * @returns {Promise<{ affected: number }>} Rows reported by PostgreSQL as inserted/updated.
   */
  async upsertBatch(rows) {
    if (!rows.length) return { affected: 0 };
    let affected = 0;
    for (let i = 0; i < rows.length; i += CHUNK) {
      const chunk = rows.slice(i, i + CHUNK);
      const placeholders = [];
      const params = [];
      let p = 1;
      for (const r of chunk) {
        this.assertRow(r);
        placeholders.push(`($${p++}, $${p++}, $${p++}, $${p++}, $${p++}, NOW())`);
        params.push(
          r.source,
          String(r.token).trim().toUpperCase(),
          String(r.pair).trim(),
          r.price_usd,
          r.calculated_at,
        );
      }
      const { rowCount } = await this.db.query(
        `
          INSERT INTO current_offchain_prices (
            source, token, pair, price_usd, calculated_at, updated_at
          )
          VALUES ${placeholders.join(", ")}
          ON CONFLICT (source, pair) DO UPDATE SET
            token = EXCLUDED.token,
            price_usd = EXCLUDED.price_usd,
            calculated_at = EXCLUDED.calculated_at,
            updated_at = NOW()
        `,
        params,
      );
      affected += rowCount ?? 0;
    }
    return { affected };
  }

  async getByTicker(symbol) {
    const res = await this.db.query(
      `
        SELECT
          p.source,
          p.token,
          p.pair,
          p.price_usd,
          p.calculated_at,
          p.updated_at
        FROM current_offchain_prices p
        WHERE UPPER(p.token) = UPPER($1)
        ORDER BY p.source, p.pair;
      `,
      [symbol],
    );

    return res.rows;
  }
}

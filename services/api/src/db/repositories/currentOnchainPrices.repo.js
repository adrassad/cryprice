import { BaseRepository } from "./base.repository.js";

export class CurrentOnchainPriceRepository {
  constructor(db) {
    this.db = db;
  }

  async upsert(object) {
    await this.db.query(
      `
        INSERT INTO current_onchain_prices (
          network_id,
          asset_id,
          price_usd,
          calculated_at,
          updated_at
        )
        VALUES ($1, $2, $3, $4, NOW())
        ON CONFLICT (network_id, asset_id)
        DO UPDATE SET
          price_usd = EXCLUDED.price_usd,
          calculated_at = EXCLUDED.calculated_at,
          updated_at = NOW();
      `,
      [
        object.network_id,
        object.asset_id,
        object.price_usd,
        object.calculated_at,
      ],
    );
  }

  async getLastPricesByNetwork(network_id) {
    const res = await this.db.query(
      `
        SELECT
          p.asset_id,
          a.symbol,
          a.address,
          p.price_usd,
          p.calculated_at
        FROM current_onchain_prices p
        INNER JOIN assets a ON a.id = p.asset_id
        WHERE p.network_id = $1;
      `,
      [network_id],
    );

    return res.rows;
  }

  /**
   * Current on-chain price for one asset on a network (source of truth when Redis is empty).
   */
  async getByNetworkAndAddress(network_id, addressLower) {
    const res = await this.db.query(
      `
        SELECT
          p.price_usd,
          p.calculated_at,
          a.symbol,
          a.address
        FROM current_onchain_prices p
        INNER JOIN assets a ON a.id = p.asset_id
        WHERE p.network_id = $1 AND lower(a.address) = lower($2)
        LIMIT 1
      `,
      [network_id, addressLower],
    );
    return res.rows[0] ?? null;
  }
}

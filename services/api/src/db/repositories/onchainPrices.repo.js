import { BaseRepository } from "./base.repository.js";

export class OnchainPriceRepository extends BaseRepository {
  constructor(db) {
    super(db, "onchain_prices", "id");
  }

  async create(object) {
    await this.db.query(
      `
        INSERT INTO onchain_prices (
          network_id,
          asset_id,
          price_usd,
          collected_at
        )
        VALUES ($1, $2, $3, $4)
      `,
      [
        object.network_id,
        object.asset_id,
        object.price_usd,
        object.collected_at,
      ],
    );
  }

  async getLastPricesByNetwork(network_id) {
    const res = await this.db.query(
      `
        SELECT DISTINCT ON (p.asset_id)
          p.asset_id,
          a.symbol,
          a.address,
          p.price_usd,
          p.collected_at
        FROM onchain_prices p
        INNER JOIN assets a ON a.id = p.asset_id
        WHERE p.network_id = $1
        ORDER BY p.asset_id, p.collected_at DESC;
      `,
      [network_id],
    );

    return res.rows;
  }
}

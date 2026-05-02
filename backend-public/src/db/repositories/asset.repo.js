// src/db/repositories/asset.repo.js

import { BaseRepository } from "./base.repository.js";

export class AssetRepository extends BaseRepository {
  constructor(db) {
    super(db, "assets", "id");
  }

  async create(object) {
    const result = await this.db.query(
      `
        INSERT INTO assets (network_id, address, symbol, decimals)
        VALUES ($1, $2, $3, $4)
        ON CONFLICT (address)
        DO UPDATE SET
          symbol = EXCLUDED.symbol,
          decimals = EXCLUDED.decimals
        RETURNING *
        `,
      [
        object.network_id,
        object.address.toLowerCase(),
        object.symbol,
        object.decimals,
      ],
    );
    return result.rows[0] || null;
  }

  async bulkUpsert(assets) {
    if (!assets.length) return;

    const chunkSize = 1000;
    for (let i = 0; i < assets.length; i += chunkSize) {
      await this.bulkUpsertChunk(assets.slice(i, i + chunkSize));
    }
  }

  async bulkUpsertChunk(assets) {
    const values = [];
    const params = [];

    assets.forEach((a, i) => {
      const idx = i * 4;
      values.push(`($${idx + 1}, $${idx + 2}, $${idx + 3}, $${idx + 4})`);

      params.push(a.network_id, a.address.toLowerCase(), a.symbol, a.decimals);
    });

    await this.db.query(
      `
    INSERT INTO assets (network_id, address, symbol, decimals)
    VALUES ${values.join(",")}
    ON CONFLICT (network_id, address)
    DO UPDATE SET
      symbol = EXCLUDED.symbol,
      decimals = EXCLUDED.decimals
  `,
      params,
    );
  }

  async findByAddress(networkId, address) {
    const res = await this.db.query(
      `SELECT * FROM assets WHERE network_id = $1 AND address = $2`,
      [networkId, address],
    );
    return res.rows[0] || null;
  }

  async findByNetwork(network_id) {
    const res = await this.db.query(
      `SELECT * FROM assets WHERE network_id = $1`,
      [network_id],
    );
    return res.rows;
  }

  async findAllBySymbol(symbol) {
    const res = await this.db.query(
      `
        SELECT 
          a.id, 
          a.address, 
          a.symbol, 
          a.decimals,
          n.name,
          n.chain_id
      FROM assets a
      JOIN networks n
          ON a.network_id = n.id
      WHERE a.symbol = $1
      ORDER BY a.address;

        `,
      [symbol.toUpperCase()],
    );
    return res.rows;
  }
}

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

  async findByIds(assetIds) {
    const ids = Array.isArray(assetIds)
      ? assetIds.filter((id) => id != null).map((id) => String(id))
      : [];
    if (!ids.length) return [];
    const res = await this.db.query(
      `SELECT * FROM assets WHERE id = ANY($1::bigint[])`,
      [ids],
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

  async updateLogoMetadata(assetId, patch) {
    if (assetId === undefined || assetId === null || assetId === "") {
      throw new Error("assetId is required");
    }
    if (!patch || typeof patch !== "object") {
      throw new Error("patch must be an object");
    }

    const allowedFields = [
      "logo_status",
      "logo_source",
      "logo_local_path",
      "logo_updated_at",
      "logo_content_hash",
      "logo_error",
    ];

    const sets = [];
    const params = [assetId];

    for (const field of allowedFields) {
      if (patch[field] !== undefined) {
        params.push(patch[field]);
        sets.push(`${field} = $${params.length}`);
      }
    }

    if (!sets.length) {
      return this.findById(assetId);
    }

    const result = await this.db.query(
      `
        UPDATE assets
        SET ${sets.join(", ")}
        WHERE id = $1
        RETURNING *
      `,
      params,
    );

    return result.rows[0] || null;
  }

  async findAssetsForTrustWalletIconSync(supportedChainIds) {
    const chainIds = Array.isArray(supportedChainIds)
      ? supportedChainIds.filter((id) => id != null).map((id) => Number(id))
      : [];
    if (!chainIds.length) return [];

    const { rows } = await this.db.query(
      `
        SELECT
          a.*,
          n.chain_id AS chain_id
        FROM assets a
        INNER JOIN networks n
          ON n.id = a.network_id
        WHERE n.enabled = TRUE
          AND a.address IS NOT NULL
          AND n.chain_id = ANY($1::int[])
          AND a.logo_source IS DISTINCT FROM 'manual'
          AND (
            a.logo_source IS NULL
            OR a.logo_source IN ('generated', 'token_list')
            OR a.logo_status IN ('pending', 'failed', 'skipped')
          )
        ORDER BY n.chain_id ASC, a.id ASC
      `,
      [chainIds],
    );

    return rows;
  }
}

//src/db/repositories/network.repo.js

import { BaseRepository } from "./base.repository.js";

export class NetworkRepository extends BaseRepository {
  constructor(db) {
    super(db, "networks", "id");
  }
  async create(network) {
    await this.db.query(
      `
        INSERT INTO networks (name, chain_id, native_symbol, enabled)
          VALUES ($1, $2, $3, $4)
          ON CONFLICT (name) DO UPDATE
          SET
            chain_id = EXCLUDED.chain_id,
            native_symbol = EXCLUDED.native_symbol,
            enabled = EXCLUDED.enabled
        `,
      [network.name, network.chain_id, network.native_symbol, network.enabled],
    );
  }
}

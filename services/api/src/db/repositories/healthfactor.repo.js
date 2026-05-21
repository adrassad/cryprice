import { BaseRepository } from "./base.repository.js";

export class HFRepository extends BaseRepository {
  constructor(db) {
    super(db, "healthfactors", "id");
  }
  async create(data) {
    const normalizedHF =
      data.healthfactor === Infinity
        ? Infinity
        : Number(data.healthfactor.toFixed(2));
    const { rowCount } = await this.db.query(
      `
        INSERT INTO healthfactors (address, protocol, network_id, collected_at, healthfactor)
        SELECT $1, $2, $3, $4, $5
        WHERE NOT EXISTS (
          SELECT 1 FROM (
            SELECT healthfactor
            FROM healthfactors
            WHERE address = $1
              AND protocol = $2
              AND network_id = $3
            ORDER BY collected_at DESC
            LIMIT 1
          ) last
          WHERE last.healthfactor IS NOT DISTINCT FROM $5
        )
        RETURNING id;
        `,
      [
        data.address,
        data.protocol,
        data.network_id,
        data.collected_at,
        normalizedHF,
      ],
    );
    return rowCount > 0;
  }
}

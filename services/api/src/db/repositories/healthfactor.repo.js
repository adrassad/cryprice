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

  async findLatestByAddresses(addresses, options = {}) {
    const normalizedAddresses = Array.isArray(addresses)
      ? [
          ...new Set(
            addresses
              .filter((address) => typeof address === "string" && address.trim())
              .map((address) => address.trim().toLowerCase()),
          ),
        ]
      : [];

    if (!normalizedAddresses.length) return [];

    const protocol =
      options.protocol === undefined || options.protocol === null || options.protocol === ""
        ? null
        : String(options.protocol).trim();

    const networkIds = Array.isArray(options.networkIds)
      ? [
          ...new Set(
            options.networkIds
              .filter((id) => id !== undefined && id !== null && id !== "")
              .map((id) => String(id)),
          ),
        ]
      : null;

    const { rows } = await this.db.query(
      `
        SELECT DISTINCT ON (LOWER(address), protocol, network_id)
          id,
          LOWER(address) AS address,
          protocol,
          network_id,
          healthfactor,
          collected_at,
          created_at
        FROM healthfactors
        WHERE LOWER(address) = ANY($1::text[])
          AND ($2::text IS NULL OR protocol = $2)
          AND ($3::bigint[] IS NULL OR network_id = ANY($3::bigint[]))
        ORDER BY LOWER(address), protocol, network_id, collected_at DESC, id DESC
      `,
      [normalizedAddresses, protocol, networkIds],
    );

    return rows;
  }

  /**
   * Latest two HF samples per (address, protocol, network_id), rn=1 is current.
   */
  async findLatestTwoByAddresses(addresses, options = {}) {
    const normalizedAddresses = Array.isArray(addresses)
      ? [
          ...new Set(
            addresses
              .filter((address) => typeof address === "string" && address.trim())
              .map((address) => address.trim().toLowerCase()),
          ),
        ]
      : [];

    if (!normalizedAddresses.length) return [];

    const protocol =
      options.protocol === undefined || options.protocol === null || options.protocol === ""
        ? "aave"
        : String(options.protocol).trim();

    const { rows } = await this.db.query(
      `
        WITH ranked AS (
          SELECT
            LOWER(address) AS address,
            protocol,
            network_id,
            healthfactor,
            collected_at,
            created_at,
            ROW_NUMBER() OVER (
              PARTITION BY LOWER(address), protocol, network_id
              ORDER BY collected_at DESC, id DESC
            ) AS rn
          FROM healthfactors
          WHERE LOWER(address) = ANY($1::text[])
            AND protocol = $2
        )
        SELECT address, protocol, network_id, healthfactor, collected_at, created_at, rn
        FROM ranked
        WHERE rn <= 2
        ORDER BY address, protocol, network_id, rn
      `,
      [normalizedAddresses, protocol],
    );

    return rows;
  }
}

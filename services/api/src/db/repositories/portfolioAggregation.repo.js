export class PortfolioAggregationRepository {
  constructor(db) {
    this.db = db;
  }

  /**
   * Raw portfolio rows for all wallets owned by an internal users.id.
   * Aggregation and USD calculations belong in the service layer.
   */
  async findRawRowsByInternalUserId(internalUserId) {
    if (internalUserId === undefined || internalUserId === null || internalUserId === "") {
      throw new Error("internalUserId is required");
    }

    const { rows } = await this.db.query(
      `
        SELECT
          w.id AS wallet_id,
          w.address AS wallet_address,
          w.label AS wallet_label,

          b.asset_id AS asset_id,
          b.balance_raw::text AS balance_raw,
          b.synced_at AS balance_synced_at,
          b.block_number AS block_number,

          a.network_id AS network_id,
          a.address AS asset_address,
          a.symbol AS asset_symbol,
          a.decimals AS asset_decimals,
          a.logo_status AS asset_logo_status,
          a.logo_local_path AS asset_logo_local_path,
          a.logo_content_hash AS asset_logo_content_hash,
          a.logo_updated_at AS asset_logo_updated_at,

          n.chain_id AS chain_id,
          n.name AS network_name,
          n.native_symbol AS native_symbol,

          p.price_usd::text AS price_usd,
          p.calculated_at AS price_calculated_at,
          p.updated_at AS price_updated_at
        FROM wallets w
        INNER JOIN wallet_portfolio_balances b
          ON b.wallet_id = w.id
        INNER JOIN assets a
          ON a.id = b.asset_id
        INNER JOIN networks n
          ON n.id = a.network_id
        LEFT JOIN current_onchain_prices p
          ON p.network_id = a.network_id
         AND p.asset_id = a.id
        WHERE w.user_id = $1
          AND n.enabled = TRUE
        ORDER BY n.id ASC, a.id ASC, w.id ASC
      `,
      [internalUserId],
    );

    return rows;
  }

  async findProtocolRowsByInternalUserId(internalUserId) {
    if (internalUserId === undefined || internalUserId === null || internalUserId === "") {
      throw new Error("internalUserId is required");
    }

    const { rows } = await this.db.query(
      `
        SELECT
          w.id AS wallet_id,
          w.address AS wallet_address,
          w.label AS wallet_label,

          b.protocol_asset_token_id AS protocol_asset_token_id,
          b.balance_raw::text AS balance_raw,
          b.synced_at AS balance_synced_at,
          b.block_number AS block_number,
          b.protocol AS protocol,
          b.position_side AS position_side,
          b.token_role AS token_role,

          n.id AS network_id,
          n.chain_id AS chain_id,
          n.name AS network_name,
          n.native_symbol AS native_symbol,

          pat.token_address AS token_address,
          pat.token_symbol AS token_symbol,
          pat.token_decimals AS token_decimals,

          ua.id AS underlying_asset_id,
          ua.address AS underlying_address,
          ua.symbol AS underlying_symbol,
          ua.decimals AS underlying_decimals,
          ua.logo_status AS underlying_logo_status,
          ua.logo_local_path AS underlying_logo_local_path,
          ua.logo_content_hash AS underlying_logo_content_hash,
          ua.logo_updated_at AS underlying_logo_updated_at,

          pa.id AS price_asset_id,
          pa.address AS price_asset_address,
          pa.symbol AS price_asset_symbol,

          p.price_usd::text AS price_usd,
          p.calculated_at AS price_calculated_at,
          p.updated_at AS price_updated_at
        FROM wallets w
        INNER JOIN wallet_protocol_position_balances b
          ON b.wallet_id = w.id
        INNER JOIN protocol_asset_tokens pat
          ON pat.id = b.protocol_asset_token_id
        INNER JOIN assets ua
          ON ua.id = b.underlying_asset_id
        INNER JOIN networks n
          ON n.id = b.network_id
        LEFT JOIN assets pa
          ON pa.id = b.price_asset_id
        LEFT JOIN current_onchain_prices p
          ON p.network_id = b.network_id
         AND p.asset_id = b.price_asset_id
        WHERE w.user_id = $1
          AND n.enabled = TRUE
        ORDER BY n.id ASC, b.protocol ASC, b.position_side ASC, ua.symbol ASC, w.id ASC
      `,
      [internalUserId],
    );

    return rows;
  }
}

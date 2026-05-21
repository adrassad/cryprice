import { BaseRepository } from "./base.repository.js";

const REQUIRED_FIELDS = [
  "network_id",
  "protocol",
  "underlying_asset_id",
  "token_address",
  "token_role",
];

export class ProtocolAssetTokenRepository extends BaseRepository {
  constructor(db) {
    super(db, "protocol_asset_tokens", "id");
  }

  _normalizeAddress(address, fieldName) {
    if (!address || typeof address !== "string") {
      throw new Error(`${fieldName} is required`);
    }
    return address.trim().toLowerCase();
  }

  _normalizeOptionalAddress(address) {
    if (address === undefined || address === null || address === "") {
      return null;
    }
    return this._normalizeAddress(address, "external_market_address");
  }

  _normalizeMetadata(metadata) {
    if (metadata === undefined || metadata === null) {
      return "{}";
    }
    if (typeof metadata === "string") {
      JSON.parse(metadata);
      return metadata;
    }
    if (typeof metadata !== "object" || Array.isArray(metadata)) {
      throw new Error("metadata must be an object or JSON string");
    }
    return JSON.stringify(metadata);
  }

  _normalizeItem(data) {
    this._assertObject(data, "protocol asset token");

    for (const field of REQUIRED_FIELDS) {
      if (data[field] === undefined || data[field] === null || data[field] === "") {
        throw new Error(`${field} is required`);
      }
    }

    return {
      network_id: data.network_id,
      protocol: String(data.protocol).trim().toLowerCase(),
      underlying_asset_id: data.underlying_asset_id,
      token_address: this._normalizeAddress(data.token_address, "token_address"),
      token_symbol:
        data.token_symbol === undefined || data.token_symbol === null
          ? null
          : String(data.token_symbol),
      token_decimals:
        data.token_decimals === undefined || data.token_decimals === null
          ? null
          : data.token_decimals,
      token_role: String(data.token_role).trim().toLowerCase(),
      price_asset_id:
        data.price_asset_id === undefined || data.price_asset_id === null
          ? null
          : data.price_asset_id,
      market_id:
        data.market_id === undefined || data.market_id === null
          ? null
          : String(data.market_id),
      external_market_address: this._normalizeOptionalAddress(
        data.external_market_address,
      ),
      metadata: this._normalizeMetadata(data.metadata),
      is_active:
        data.is_active === undefined || data.is_active === null
          ? true
          : Boolean(data.is_active),
    };
  }

  async upsertProtocolAssetToken(data) {
    const item = this._normalizeItem(data);
    const { rows } = await this.db.query(
      `
        INSERT INTO protocol_asset_tokens (
          network_id,
          protocol,
          underlying_asset_id,
          token_address,
          token_symbol,
          token_decimals,
          token_role,
          price_asset_id,
          market_id,
          external_market_address,
          metadata,
          is_active
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11::jsonb, $12)
        ON CONFLICT (network_id, protocol, underlying_asset_id, token_role)
        DO UPDATE SET
          token_address = EXCLUDED.token_address,
          token_symbol = EXCLUDED.token_symbol,
          token_decimals = EXCLUDED.token_decimals,
          price_asset_id = EXCLUDED.price_asset_id,
          market_id = EXCLUDED.market_id,
          external_market_address = EXCLUDED.external_market_address,
          metadata = EXCLUDED.metadata,
          is_active = EXCLUDED.is_active
        RETURNING *
      `,
      [
        item.network_id,
        item.protocol,
        item.underlying_asset_id,
        item.token_address,
        item.token_symbol,
        item.token_decimals,
        item.token_role,
        item.price_asset_id,
        item.market_id,
        item.external_market_address,
        item.metadata,
        item.is_active,
      ],
    );
    return rows[0] ?? null;
  }

  async bulkUpsertProtocolAssetTokens(items) {
    if (!Array.isArray(items)) {
      throw new Error("items must be an array");
    }
    if (!items.length) return [];

    const rows = [];
    for (const item of items) {
      const row = await this.upsertProtocolAssetToken(item);
      if (row) rows.push(row);
    }
    return rows;
  }

  async findByProtocolAndNetwork(protocol, networkId) {
    const { rows } = await this.db.query(
      `
        SELECT *
        FROM protocol_asset_tokens
        WHERE protocol = $1 AND network_id = $2
        ORDER BY underlying_asset_id ASC, token_role ASC
      `,
      [String(protocol).trim().toLowerCase(), networkId],
    );
    return rows;
  }

  async findActiveByNetwork(networkId) {
    const { rows } = await this.db.query(
      `
        SELECT *
        FROM protocol_asset_tokens
        WHERE network_id = $1 AND is_active = TRUE
        ORDER BY protocol ASC, underlying_asset_id ASC, token_role ASC
      `,
      [networkId],
    );
    return rows;
  }

  async findByTokenAddress(networkId, tokenAddress) {
    const { rows } = await this.db.query(
      `
        SELECT *
        FROM protocol_asset_tokens
        WHERE network_id = $1 AND token_address = $2
        ORDER BY protocol ASC, underlying_asset_id ASC, token_role ASC
      `,
      [networkId, this._normalizeAddress(tokenAddress, "tokenAddress")],
    );
    return rows;
  }

  async findByUnderlyingAssetId(protocol, networkId, underlyingAssetId) {
    const { rows } = await this.db.query(
      `
        SELECT *
        FROM protocol_asset_tokens
        WHERE protocol = $1
          AND network_id = $2
          AND underlying_asset_id = $3
        ORDER BY token_role ASC
      `,
      [String(protocol).trim().toLowerCase(), networkId, underlyingAssetId],
    );
    return rows;
  }

  async findByRole(protocol, networkId, tokenRole) {
    const { rows } = await this.db.query(
      `
        SELECT *
        FROM protocol_asset_tokens
        WHERE protocol = $1
          AND network_id = $2
          AND token_role = $3
        ORDER BY underlying_asset_id ASC, token_address ASC
      `,
      [
        String(protocol).trim().toLowerCase(),
        networkId,
        String(tokenRole).trim().toLowerCase(),
      ],
    );
    return rows;
  }
}

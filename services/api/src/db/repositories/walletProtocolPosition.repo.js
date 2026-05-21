import { BaseRepository } from "./base.repository.js";

const UPSERT_SQL = `
  INSERT INTO wallet_protocol_position_balances (
    wallet_id,
    network_id,
    protocol,
    protocol_asset_token_id,
    underlying_asset_id,
    price_asset_id,
    position_side,
    token_role,
    balance_raw,
    synced_at,
    block_number,
    created_at,
    updated_at
  )
  VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10::timestamptz, $11, NOW(), NOW())
  ON CONFLICT (wallet_id, protocol_asset_token_id)
  DO UPDATE SET
    network_id = EXCLUDED.network_id,
    protocol = EXCLUDED.protocol,
    underlying_asset_id = EXCLUDED.underlying_asset_id,
    price_asset_id = EXCLUDED.price_asset_id,
    position_side = EXCLUDED.position_side,
    token_role = EXCLUDED.token_role,
    balance_raw = EXCLUDED.balance_raw,
    synced_at = EXCLUDED.synced_at,
    block_number = EXCLUDED.block_number,
    updated_at = NOW()
`;

const DELETE_ROW_SQL = `
  DELETE FROM wallet_protocol_position_balances
  WHERE wallet_id = $1 AND protocol_asset_token_id = $2
`;

export class WalletProtocolPositionRepository extends BaseRepository {
  constructor(db) {
    super(db, "wallet_protocol_position_balances", "id");
  }

  _parseBalanceRawStrict(balanceRaw) {
    if (balanceRaw === null || balanceRaw === undefined) {
      throw new Error("balanceRaw is required");
    }
    try {
      return typeof balanceRaw === "bigint"
        ? balanceRaw
        : BigInt(String(balanceRaw).trim());
    } catch {
      throw new Error("balanceRaw must be an integer string or bigint");
    }
  }

  async findByWalletId(walletId) {
    const { rows } = await this.db.query(
      `
        SELECT *
        FROM wallet_protocol_position_balances
        WHERE wallet_id = $1
        ORDER BY network_id ASC, protocol ASC, position_side ASC, underlying_asset_id ASC
      `,
      [walletId],
    );
    return rows;
  }

  _computeDesiredPositiveProtocolTokenIds(collected) {
    const ids = new Set();
    for (const n of Array.isArray(collected?.networks) ? collected.networks : []) {
      if (!n || n.protocolStatus !== "ok") continue;
      for (const p of Array.isArray(n.protocolPositions) ? n.protocolPositions : []) {
        if (!p || p.protocolAssetTokenId == null) continue;
        ids.add(String(p.protocolAssetTokenId));
      }
    }
    return ids;
  }

  _computeOkNetworkIds(collected) {
    const ids = new Set();
    for (const n of Array.isArray(collected?.networks) ? collected.networks : []) {
      if (!n || n.protocolStatus !== "ok" || n.networkId == null) continue;
      ids.add(String(n.networkId));
    }
    return ids;
  }

  async syncCollectedSnapshotWithLock(walletId, collected, syncedAtIso) {
    const client = await this.db.pool.connect();
    let inTransaction = false;
    try {
      await client.query("BEGIN");
      inTransaction = true;

      for (const n of Array.isArray(collected?.networks) ? collected.networks : []) {
        if (!n || n.protocolStatus !== "ok") continue;
        for (const p of Array.isArray(n.protocolPositions) ? n.protocolPositions : []) {
          if (!p || p.protocolAssetTokenId == null || p.balanceRaw == null) continue;
          const balanceRaw = this._parseBalanceRawStrict(p.balanceRaw);
          if (balanceRaw <= 0n) continue;
          await client.query(UPSERT_SQL, [
            walletId,
            n.networkId,
            p.protocol,
            p.protocolAssetTokenId,
            p.underlyingAssetId,
            p.priceAssetId,
            p.positionSide,
            p.tokenRole,
            balanceRaw.toString(),
            syncedAtIso,
            null,
          ]);
        }
      }

      const okNetworkIds = this._computeOkNetworkIds(collected);
      const desiredIds = this._computeDesiredPositiveProtocolTokenIds(collected);
      const { rows: existing } = await client.query(
        `
          SELECT protocol_asset_token_id, network_id
          FROM wallet_protocol_position_balances
          WHERE wallet_id = $1
        `,
        [walletId],
      );

      for (const row of existing) {
        if (row?.network_id == null || row?.protocol_asset_token_id == null) continue;
        if (!okNetworkIds.has(String(row.network_id))) continue;
        if (desiredIds.has(String(row.protocol_asset_token_id))) continue;
        await client.query(DELETE_ROW_SQL, [
          walletId,
          row.protocol_asset_token_id,
        ]);
      }

      await client.query("COMMIT");
    } catch (e) {
      if (inTransaction) await client.query("ROLLBACK");
      throw e;
    } finally {
      client.release();
    }
  }
}

// src/db/repositories/walletPortfolio.repo.js
import { BaseRepository } from "./base.repository.js";

const UPSERT_SQL = `
  INSERT INTO wallet_portfolio_balances (
    wallet_id,
    asset_id,
    balance_raw,
    synced_at,
    block_number,
    created_at,
    updated_at
  )
  VALUES ($1, $2, $3, $4::timestamptz, $5, NOW(), NOW())
  ON CONFLICT (wallet_id, asset_id)
  DO UPDATE SET
    balance_raw = EXCLUDED.balance_raw,
    synced_at = EXCLUDED.synced_at,
    block_number = EXCLUDED.block_number,
    updated_at = NOW()
`;

const DELETE_ROW_SQL = `
  DELETE FROM wallet_portfolio_balances
  WHERE wallet_id = $1 AND asset_id = $2
`;

export class WalletPortfolioRepository extends BaseRepository {
  constructor(db) {
    super(db, "wallet_portfolio_balances", "id");
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
      throw new Error(
        "balanceRaw must be an integer string or bigint suitable for NUMERIC(78,0)",
      );
    }
  }

  /**
   * Insert or update only when balance_raw > 0. For zero use deleteByWalletAndAsset or syncBalance.
   */
  async upsertBalance(walletId, assetId, balanceRaw, syncedAt, blockNumber = null) {
    const n = this._parseBalanceRawStrict(balanceRaw);
    if (n <= 0n) {
      throw new Error(
        "balance_raw must be > 0; use deleteByWalletAndAsset(walletId, assetId) or syncBalance when balance is zero",
      );
    }
    const balanceParam = typeof balanceRaw === "string" ? balanceRaw.trim() : n.toString();
    const { rows } = await this.db.query(
      `
        INSERT INTO wallet_portfolio_balances (
          wallet_id,
          asset_id,
          balance_raw,
          synced_at,
          block_number,
          created_at,
          updated_at
        )
        VALUES ($1, $2, $3, $4, $5, NOW(), NOW())
        ON CONFLICT (wallet_id, asset_id)
        DO UPDATE SET
          balance_raw = EXCLUDED.balance_raw,
          synced_at = EXCLUDED.synced_at,
          block_number = EXCLUDED.block_number,
          updated_at = NOW()
        RETURNING *
      `,
      [walletId, assetId, balanceParam, syncedAt, blockNumber],
    );
    return rows[0] ?? null;
  }

  /**
   * Positive balance → upsert; zero or negative → delete row (no mixed upsert logic in SQL).
   */
  async syncBalance(walletId, assetId, balanceRaw, syncedAt, blockNumber = null) {
    const n = this._parseBalanceRawStrict(balanceRaw);
    if (n <= 0n) {
      return this.deleteByWalletAndAsset(walletId, assetId);
    }
    return this.upsertBalance(walletId, assetId, balanceRaw, syncedAt, blockNumber);
  }

  async deleteByWalletAndAsset(walletId, assetId) {
    const { rows } = await this.db.query(
      `
        DELETE FROM wallet_portfolio_balances
        WHERE wallet_id = $1 AND asset_id = $2
        RETURNING *
      `,
      [walletId, assetId],
    );
    return rows[0] ?? null;
  }

  async findByWalletId(walletId) {
    const { rows } = await this.db.query(
      `
        SELECT *
        FROM wallet_portfolio_balances
        WHERE wallet_id = $1
        ORDER BY asset_id ASC
      `,
      [walletId],
    );
    return rows;
  }

  /**
   * All portfolio rows for every wallet owned by the Telegram user (users.telegram_id).
   */
  async findByUserTelegramId(userTelegramId) {
    const { rows } = await this.db.query(
      `
        SELECT b.*
        FROM wallet_portfolio_balances b
        INNER JOIN wallets w ON w.id = b.wallet_id
        WHERE w.user_id = $1
        ORDER BY b.wallet_id ASC, b.asset_id ASC
      `,
      [userTelegramId],
    );
    return rows;
  }

  /**
   * Same as findByUserTelegramId: wallets.user_id references users.telegram_id.
   */
  async findByUserId(userId) {
    return this.findByUserTelegramId(userId);
  }

  _computeDesiredPositiveAssetIds(collected) {
    const ids = new Set();
    const nets = collected?.networks;
    if (!Array.isArray(nets)) return ids;
    for (const n of nets) {
      if (!n || n.status !== "ok" || !Array.isArray(n.tokens)) continue;
      for (const t of n.tokens) {
        if (!t || t.assetId == null || t.assetId === "") continue;
        ids.add(String(t.assetId));
      }
    }
    return ids;
  }

  _computeOkNetworkIds(collected) {
    const ids = new Set();
    const nets = collected?.networks;
    if (!Array.isArray(nets)) return ids;
    for (const n of nets) {
      if (!n || n.status !== "ok" || n.networkId == null) continue;
      ids.add(n.networkId);
    }
    return ids;
  }

  async _acquireWalletSyncLock(client, walletId, timeoutMs, retryMs) {
    const lockKey = String(walletId);
    const startedAt = Date.now();
    for (;;) {
      const { rows } = await client.query(
        `SELECT pg_try_advisory_lock($1::bigint) AS locked`,
        [lockKey],
      );
      if (rows[0]?.locked) return;
      if (Date.now() - startedAt >= timeoutMs) {
        throw new Error("SYNC_IN_PROGRESS");
      }
      await new Promise((resolve) => setTimeout(resolve, retryMs));
    }
  }

  async _releaseWalletSyncLock(client, walletId) {
    await client.query(`SELECT pg_advisory_unlock($1::bigint)`, [String(walletId)]);
  }

  async syncCollectedSnapshotWithLock(
    walletId,
    collected,
    syncedAtIso,
    { lockTimeoutMs = 20000, lockRetryMs = 250 } = {},
  ) {
    const client = await this.db.pool.connect();
    let inTransaction = false;
    try {
      await this._acquireWalletSyncLock(client, walletId, lockTimeoutMs, lockRetryMs);
      await client.query("BEGIN");
      inTransaction = true;

      for (const n of Array.isArray(collected?.networks) ? collected.networks : []) {
        if (!n || n.status !== "ok" || !Array.isArray(n.tokens)) continue;
        for (const t of n.tokens) {
          if (!t || t.assetId == null || t.balanceRaw == null) continue;
          await client.query(UPSERT_SQL, [
            walletId,
            t.assetId,
            t.balanceRaw,
            syncedAtIso,
            null,
          ]);
        }
      }

      const okNetworkIds = this._computeOkNetworkIds(collected);
      const desiredAssetIds = this._computeDesiredPositiveAssetIds(collected);
      const { rows: existing } = await client.query(
        `
          SELECT b.asset_id, a.network_id
          FROM wallet_portfolio_balances b
          INNER JOIN assets a ON a.id = b.asset_id
          WHERE b.wallet_id = $1
        `,
        [walletId],
      );
      for (const row of existing) {
        if (row?.network_id == null || row?.asset_id == null) continue;
        if (!okNetworkIds.has(row.network_id)) continue;
        if (desiredAssetIds.has(String(row.asset_id))) continue;
        await client.query(DELETE_ROW_SQL, [walletId, row.asset_id]);
      }

      await client.query("COMMIT");
    } catch (e) {
      if (inTransaction) await client.query("ROLLBACK");
      throw e;
    } finally {
      try {
        await this._releaseWalletSyncLock(client, walletId);
      } finally {
        client.release();
      }
    }
  }
}

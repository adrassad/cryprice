// src/services/portfolio/portfolio.service.js
import { db } from "../../db/index.js";
import { HttpError } from "../../api/errors/httpError.js";
import pLimit from "p-limit";
import {
  getPortfolioByWalletId,
  setPortfolioByWalletId,
} from "../../cache/portfolio.cache.js";
import { getUserWallets } from "../wallet/wallet.service.js";
import { collectWalletPortfolio } from "./portfolio.collector.js";
import { extractNativePositions, enrichNativePositionsWithLogoUrl } from "./portfolio.sync.helpers.js";
import { isValidPortfolioSnapshot } from "./portfolio.cache.validation.js";

function normalizeWalletAddressInput(walletAddress) {
  if (!walletAddress || typeof walletAddress !== "string") {
    throw new HttpError(
      400,
      "INVALID_ADDRESS",
      "walletAddress is required.",
    );
  }
  const addr = walletAddress.trim().toLowerCase();
  if (!/^0x[a-f0-9]{40}$/.test(addr)) {
    throw new HttpError(
      400,
      "INVALID_ADDRESS",
      "walletAddress must be a 42-char hex EVM address.",
    );
  }
  return addr;
}

async function loadAssetsMapForIds(assetIds) {
  const map = new Map();
  const ids = [...assetIds].filter((id) => id != null);
  if (!ids.length) return map;
  const rows = await db.assets.findByIds(ids);
  for (const row of rows) {
    if (row?.id != null) map.set(String(row.id), row);
  }
  return map;
}

/**
 * ERC20 positions from DB + enrichment (source of truth for tokens in portfolio table).
 */
async function buildErc20SnapshotFromDb(walletId) {
  const rows = await db.walletPortfolio.findByWalletId(walletId);
  if (!rows.length) {
    return {
      erc20Positions: [],
      syncedAt: null,
    };
  }

  const assetIds = new Set(
    rows.map((r) => r.asset_id).filter((id) => id != null),
  );
  const assetMap = await loadAssetsMapForIds(assetIds);

  let latestSynced = null;
  const erc20Positions = [];

  for (const row of rows) {
    if (row?.asset_id == null) continue;

    const asset = assetMap.get(String(row.asset_id));
    if (!asset) continue;

    const sa = row.synced_at;
    const iso =
      sa instanceof Date ? sa.toISOString() : sa ? String(sa) : null;
    if (iso && (!latestSynced || iso > latestSynced)) latestSynced = iso;

    erc20Positions.push({
      kind: "erc20",
      assetId: String(row.asset_id),
      networkId: asset.network_id,
      address: String(asset.address ?? "").toLowerCase(),
      symbol: asset.symbol != null ? String(asset.symbol) : "",
      decimals:
        typeof asset.decimals === "number" && Number.isFinite(asset.decimals)
          ? asset.decimals
          : Number(asset.decimals) || 0,
      balanceRaw: String(row.balance_raw),
      syncedAt: iso,
      blockNumber: row.block_number != null ? String(row.block_number) : null,
    });
  }

  return {
    erc20Positions,
    syncedAt: latestSynced,
  };
}

async function buildProtocolSnapshotFromDb(walletId) {
  const rows = await db.walletProtocolPositions.findByWalletId(walletId);
  const protocolPositions = rows.map((row) => ({
    kind: "protocol",
    protocol: row.protocol,
    protocolAssetTokenId: String(row.protocol_asset_token_id),
    networkId: row.network_id,
    tokenRole: row.token_role,
    positionSide: row.position_side,
    underlyingAssetId: String(row.underlying_asset_id),
    priceAssetId: row.price_asset_id != null ? String(row.price_asset_id) : null,
    balanceRaw: String(row.balance_raw),
    syncedAt:
      row.synced_at instanceof Date
        ? row.synced_at.toISOString()
        : row.synced_at
          ? String(row.synced_at)
          : null,
    blockNumber: row.block_number != null ? String(row.block_number) : null,
  }));

  return {
    supplied: protocolPositions.filter((p) => p.positionSide === "supplied"),
    borrowed: protocolPositions.filter((p) => p.positionSide === "borrowed"),
  };
}

function mergeSnapshot(walletId, collectedAtIso, nativePositions, dbPart, protocolPart) {
  const native = Array.isArray(nativePositions) ? nativePositions : [];
  const erc20 = Array.isArray(dbPart?.erc20Positions) ? dbPart.erc20Positions : [];
  return {
    walletId: String(walletId),
    syncedAt: collectedAtIso ?? dbPart?.syncedAt ?? null,
    native,
    positions: [...native, ...erc20],
    walletHoldings: [...native, ...erc20],
    protocolPositions: protocolPart ?? { supplied: [], borrowed: [] },
  };
}

/**
 * Read-through: Redis → DB → populate Redis (ERC20 from DB; native only present after sync).
 */
export async function getWalletPortfolio(walletId) {
  if (walletId == null) {
    throw new HttpError(400, "INVALID_REQUEST", "walletId is required.");
  }

  const cached = await getPortfolioByWalletId(walletId);
  if (isValidPortfolioSnapshot(walletId, cached)) {
    return cached;
  }

  const dbPart = await buildErc20SnapshotFromDb(walletId);
  const snapshot = mergeSnapshot(
    walletId,
    dbPart.syncedAt,
    [],
    dbPart,
    await buildProtocolSnapshotFromDb(walletId),
  );

  await setPortfolioByWalletId(walletId, snapshot);
  return snapshot;
}

/**
 * All wallets for the authenticated user (`users.id` from JWT).
 */
export async function getUserPortfolio(internalUserId) {
  if (internalUserId == null) {
    throw new HttpError(400, "INVALID_REQUEST", "userId is required.");
  }

  const user = await db.users.findByInternalId(internalUserId);
  if (!user) {
    throw new HttpError(404, "USER_NOT_FOUND", "User not found.");
  }

  const walletsMap = await getUserWallets(user.id);
  const wallets = [];

  for (const w of walletsMap.values()) {
    const portfolio = await getWalletPortfolio(w.id);
    wallets.push({
      walletId: w.id,
      address: w.address,
      label: w.label,
      portfolio,
    });
  }

  return {
    userId: String(internalUserId),
    wallets,
  };
}

/**
 * Ensures wallet belongs to the user resolved from internal `users.id` (JWT subject).
 */
export async function assertWalletOwnedByInternalUser(internalUserId, walletId) {
  if (internalUserId == null) {
    throw new HttpError(400, "INVALID_REQUEST", "userId is required.");
  }
  if (walletId == null) {
    throw new HttpError(400, "INVALID_REQUEST", "walletId is required.");
  }

  const user = await db.users.findByInternalId(internalUserId);
  if (!user) {
    throw new HttpError(404, "USER_NOT_FOUND", "User not found.");
  }

  const walletRow = await db.wallets.findById(walletId);
  if (!walletRow) {
    throw new HttpError(404, "WALLET_NOT_FOUND", "Wallet not found.");
  }

  if (String(walletRow.user_id) !== String(user.id)) {
    throw new HttpError(
      403,
      "FORBIDDEN",
      "Wallet does not belong to the current user.",
    );
  }

  return walletRow;
}

export async function getWalletPortfolioForAuth(internalUserId, walletId) {
  await assertWalletOwnedByInternalUser(internalUserId, walletId);
  return getWalletPortfolio(walletId);
}

/**
 * Collect on-chain balances, persist ERC20 rows to DB, prune stale rows for successfully
 * scanned networks, refresh Redis snapshot (DB + native from the same collector run).
 * DB writes + pruning + lock are delegated to repository.
 */
export async function syncWalletPortfolio(walletId, walletAddress) {
  if (walletId == null) {
    throw new HttpError(400, "INVALID_REQUEST", "walletId is required.");
  }

  const normalized = normalizeWalletAddressInput(walletAddress);

  const walletRow = await db.wallets.findById(walletId);
  if (!walletRow) {
    throw new HttpError(404, "WALLET_NOT_FOUND", "Wallet not found.");
  }
  if (String(walletRow.address).toLowerCase() !== normalized) {
    throw new HttpError(
      400,
      "WALLET_ADDRESS_MISMATCH",
      "Wallet address does not match stored record.",
    );
  }

  try {
    const collected = await collectWalletPortfolio(normalized);
    const syncedAtIso =
      collected.collectedAt != null ? collected.collectedAt : new Date().toISOString();
    await db.walletPortfolio.syncCollectedSnapshotWithLock(
      walletId,
      collected,
      syncedAtIso,
    );
    await db.walletProtocolPositions.syncCollectedSnapshotWithLock(
      walletId,
      collected,
      syncedAtIso,
    );

    const dbPart = await buildErc20SnapshotFromDb(walletId);
    const protocolPart = await buildProtocolSnapshotFromDb(walletId);
    const nativePositions = await enrichNativePositionsWithLogoUrl(
      extractNativePositions(collected),
    );
    const snapshot = mergeSnapshot(
      walletId,
      syncedAtIso,
      nativePositions,
      dbPart,
      protocolPart,
    );

    await setPortfolioByWalletId(walletId, snapshot);
    return snapshot;
  } catch (e) {
    if (e?.message === "SYNC_IN_PROGRESS") {
      throw new HttpError(
        409,
        "SYNC_IN_PROGRESS",
        "Wallet sync is already in progress. Try again later.",
      );
    }
    throw e;
  }
}

/**
 * Manual sync for authenticated user (`users.id`). If `walletIdParam` is set, only that wallet
 * (must belong to the user); otherwise all user wallets are synced sequentially.
 */
export async function syncUserPortfolios(internalUserId, walletIdParam) {
  const user = await db.users.findByInternalId(internalUserId);
  if (!user) {
    throw new HttpError(404, "USER_NOT_FOUND", "User not found.");
  }

  const walletsMap = await getUserWallets(user.id);
  const list = [...walletsMap.values()];

  const targetId =
    walletIdParam === undefined ||
    walletIdParam === null ||
    walletIdParam === ""
      ? null
      : String(walletIdParam);

  if (targetId != null) {
    const w = list.find((x) => String(x.id) === targetId);
    if (!w) {
      throw new HttpError(
        404,
        "WALLET_NOT_FOUND",
        "Wallet not found for this user.",
      );
    }
    const portfolio = await syncWalletPortfolio(w.id, w.address);
    const syncedAt = portfolio.syncedAt ?? null;
    return {
      meta: {
        mode: "single",
        wallet_id: w.id,
        synced_at: syncedAt,
        stale: syncedAt == null,
      },
      results: [
        {
          wallet_id: w.id,
          meta: { synced_at: syncedAt, stale: syncedAt == null },
          portfolio,
        },
      ],
      errors: [],
    };
  }

  const results = [];
  const errors = [];
  let latestSynced = null;

  for (const w of list) {
    try {
      const portfolio = await syncWalletPortfolio(w.id, w.address);
      const syncedAt = portfolio.syncedAt ?? null;
      if (syncedAt && (!latestSynced || syncedAt > latestSynced)) {
        latestSynced = syncedAt;
      }
      results.push({
        wallet_id: w.id,
        meta: { synced_at: syncedAt, stale: syncedAt == null },
        portfolio,
      });
    } catch (e) {
      const code = e instanceof HttpError ? e.code : "SYNC_FAILED";
      const message =
        e instanceof HttpError ? e.message : e?.message || "Sync failed.";
      errors.push({
        wallet_id: w.id,
        error: { code, message },
      });
    }
  }

  return {
    meta: {
      mode: "all",
      synced_at: latestSynced,
      stale:
        results.length === 0 ||
        results.some((r) => r.meta.stale),
    },
    results,
    errors,
  };
}

const WALLET_PAGE_SIZE = 1000;

async function fetchAllWalletsFromDb() {
  const all = [];
  let offset = 0;
  for (;;) {
    const page = await db.wallets.findAll({
      limit: WALLET_PAGE_SIZE,
      offset,
    });
    if (!page.length) break;
    all.push(...page);
    if (page.length < WALLET_PAGE_SIZE) break;
    offset += WALLET_PAGE_SIZE;
  }
  return all;
}

const PORTFOLIO_CRON_DEFAULT_CONCURRENCY = 3;

/**
 * Batch sync for cron / ops: load all wallets from DB, sync each with bounded parallelism.
 * Single-wallet failures are logged (wallet id, address, reason); they do not abort the batch.
 */
export async function syncAllWalletPortfolios(options = {}) {
  const concurrency =
    typeof options.concurrency === "number" && options.concurrency > 0
      ? options.concurrency
      : PORTFOLIO_CRON_DEFAULT_CONCURRENCY;

  const wallets = await fetchAllWalletsFromDb();
  const limit = pLimit(concurrency);
  let ok = 0;
  let failed = 0;

  await Promise.all(
    wallets.map((w) =>
      limit(async () => {
        try {
          await syncWalletPortfolio(w.id, w.address);
          ok++;
        } catch (e) {
          failed++;
          const reason =
            e instanceof HttpError
              ? `${e.code}: ${e.message}`
              : e?.message || String(e);
          console.error(
            "[portfolio][batch] sync failed",
            JSON.stringify({
              ts: new Date().toISOString(),
              walletId: w.id,
              address: w.address,
              reason,
            }),
          );
        }
      }),
    ),
  );

  return {
    total: wallets.length,
    ok,
    failed,
  };
}

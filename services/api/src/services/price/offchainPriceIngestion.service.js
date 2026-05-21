import { db } from "../../db/index.js";
import {
  COINGECKO_MAX_PAGES,
  coinGeckoInterPageDelay,
  fetchBinanceSpotUsdLikePrices,
  fetchBybitSpotUsdLikePrices,
  fetchCoinGeckoUsdMarketsPage,
} from "./offchainProviderClients.js";
import { OFFCHAIN_SOURCES } from "./offchainPriceNormalize.js";

export { OFFCHAIN_SOURCES };

async function persistSourceBatch(source, rows, collectedAt) {
  if (!rows.length) return;
  const history = rows.map((r) => ({
    source,
    token: r.token,
    pair: r.pair,
    price_usd: r.priceUsd,
    collected_at: collectedAt,
  }));
  const current = rows.map((r) => ({
    source,
    token: r.token,
    pair: r.pair,
    price_usd: r.priceUsd,
    calculated_at: collectedAt,
  }));
  await db.offchainPrices.insertHistoryBatch(history);
  await db.currentOffchainPrices.upsertBatch(current);
}

/**
 * CoinGecko-only persistence with real insert/skip counts from PostgreSQL rowCount.
 */
async function persistCoinGeckoBatch(collectedAt, rows) {
  const attempted = rows.length;
  if (!attempted) {
    console.log(
      "[coingecko] persist: attempted=0 history_inserted=0 history_skipped=0 current_upserted=0",
    );
    return { historyInserted: 0, historySkipped: 0, currentAffected: 0 };
  }

  const source = OFFCHAIN_SOURCES.COINGECKO;
  const history = rows.map((r) => ({
    source,
    token: r.token,
    pair: r.pair,
    price_usd: r.priceUsd,
    collected_at: collectedAt,
  }));
  const current = rows.map((r) => ({
    source,
    token: r.token,
    pair: r.pair,
    price_usd: r.priceUsd,
    calculated_at: collectedAt,
  }));

  try {
    const { inserted: historyInserted } =
      await db.offchainPrices.insertHistoryBatch(history);
    const historySkipped = attempted - historyInserted;
    const { affected: currentUpserted } =
      await db.currentOffchainPrices.upsertBatch(current);
    console.log(
      `[coingecko] persist: attempted=${attempted} history_inserted=${historyInserted} history_skipped=${historySkipped} current_upserted=${currentUpserted}`,
    );
    return {
      historyInserted,
      historySkipped,
      currentAffected: currentUpserted,
    };
  } catch (e) {
    console.error(
      `[coingecko] ERROR stage=persist message=${e?.message || e}`,
      new Date().toISOString(),
    );
    throw e;
  }
}

/**
 * CoinGecko: fetch page-by-page and persist after each page so a failure on a later page
 * does not discard successful earlier pages (rate limits are per-request).
 */
async function ingestCoinGeckoPaged(collectedAt) {
  const perPage = 250;
  const pauseMs = 2000;
  const hasKey = Boolean(
    (process.env.COINGECKO_API_KEY ?? process.env.COINGECKO_DEMO_API_KEY)?.trim(),
  );
  if (!hasKey) {
    console.warn(
      "[offchain] coingecko: set COINGECKO_API_KEY or COINGECKO_DEMO_API_KEY (Demo key from CoinGecko) for reliable quotas; unauthenticated calls often hit 429",
      new Date().toISOString(),
    );
  }

  let pages = 0;
  let totalFetched = 0;
  let totalNormalized = 0;
  let totalInserted = 0;
  let totalSkipped = 0;

  for (let page = 1; page <= COINGECKO_MAX_PAGES; page += 1) {
    const pageResult = await fetchCoinGeckoUsdMarketsPage(page, { perPage });
    const { rows, rawFetched, normalized } = pageResult;

    if (rows.length === 0) {
      if (page === 1) {
        console.error(
          "[offchain] coingecko: page 1 produced 0 rows — check HTTP errors above, API key, and rate limits",
          new Date().toISOString(),
        );
      }
      break;
    }

    pages += 1;
    totalFetched += rawFetched;
    totalNormalized += normalized;

    const { historyInserted, historySkipped } = await persistCoinGeckoBatch(
      collectedAt,
      rows,
    );
    totalInserted += historyInserted;
    totalSkipped += historySkipped;

    if (rows.length < perPage) break;
    await coinGeckoInterPageDelay(pauseMs);
  }

  console.log(
    `[coingecko] summary: pages=${pages} total_fetched=${totalFetched} total_normalized=${totalNormalized} total_inserted=${totalInserted} total_skipped=${totalSkipped}`,
    new Date().toISOString(),
  );
}

/**
 * Full pass: Binance + Bybit + paginated CoinGecko. Writes history + current rows keyed by `(source, pair)`.
 */
export async function syncOffchainPricesFromProviders() {
  const collectedAt = new Date();

  try {
    const binance = await fetchBinanceSpotUsdLikePrices();
    await persistSourceBatch(OFFCHAIN_SOURCES.BINANCE, binance, collectedAt);
    console.log(
      `[offchain] binance persisted ${binance.length} quotes`,
      collectedAt.toISOString(),
    );
  } catch (e) {
    console.error(
      "[offchain] binance ingest failed:",
      new Date().toISOString(),
      e?.message || e,
    );
  }

  try {
    const bybit = await fetchBybitSpotUsdLikePrices();
    await persistSourceBatch(OFFCHAIN_SOURCES.BYBIT, bybit, collectedAt);
    console.log(
      `[offchain] bybit persisted ${bybit.length} quotes`,
      collectedAt.toISOString(),
    );
  } catch (e) {
    console.error(
      "[offchain] bybit ingest failed:",
      new Date().toISOString(),
      e?.message || e,
    );
  }

  try {
    await ingestCoinGeckoPaged(collectedAt);
  } catch (e) {
    console.error(
      `[coingecko] ERROR stage=ingest message=${e?.message || e}`,
      new Date().toISOString(),
    );
  }
}

/** Process-local single-flight: bootstrap background warmup vs cron must not overlap long bulk sync. */
let offchainBulkSyncInProgress = false;

/**
 * Runs full Binance + Bybit + CoinGecko sync when no other bulk run is active.
 * CoinGecko retries stay inside this job and do not block API startup when invoked via `void` from bootstrap/cron kickoff.
 */
export async function runOffchainBulkSyncIfIdle() {
  if (offchainBulkSyncInProgress) {
    console.log(
      "⏭ Off-chain bulk sync skipped — already in progress",
      new Date().toISOString(),
    );
    return;
  }
  offchainBulkSyncInProgress = true;
  console.log(
    "🛰 Off-chain bulk sync starting (background job; API is not waiting for this)",
    new Date().toISOString(),
  );
  try {
    await syncOffchainPricesFromProviders();
    console.log(
      "✅ Off-chain bulk sync finished",
      new Date().toISOString(),
    );
  } catch (e) {
    console.error(
      "❌ Off-chain bulk sync failed:",
      new Date().toISOString(),
      e?.message || e,
    );
  } finally {
    offchainBulkSyncInProgress = false;
  }
}

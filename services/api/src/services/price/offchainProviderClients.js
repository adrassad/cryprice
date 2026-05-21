/**
 * HTTP clients for public spot/USD price endpoints (no API keys).
 * Binance: full book ticker list (all symbols) in one call.
 * Bybit: v5 spot tickers (full list) in one call.
 * CoinGecko: paginated /coins/markets vs USD.
 */

import {
  isUsdLikeCexSpotSymbol,
  normalizeOffchainTokenSymbol,
  spotPairSymbolToBaseToken,
} from "./offchainPriceNormalize.js";

async function fetchJson(url) {
  const res = await fetch(url, {
    headers: { Accept: "application/json" },
  });
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`HTTP ${res.status} ${url}: ${text.slice(0, 200)}`);
  }
  return res.json();
}

function delay(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

/**
 * @returns {Promise<Array<{ pair: string, token: string, priceUsd: number }>>}
 * All **USDT/USDC/...**-quoted spot symbols; `pair` is the exchange symbol (e.g. BTCUSDT); `token` is normalized base.
 */
export async function fetchBinanceSpotUsdLikePrices() {
  const data = await fetchJson("https://api.binance.com/api/v3/ticker/price");
  if (!Array.isArray(data)) {
    throw new Error("binance: expected array from /api/v3/ticker/price");
  }
  const out = [];
  for (const row of data) {
    const sym = row?.symbol;
    if (!sym || !isUsdLikeCexSpotSymbol(sym)) continue;
    const pair = String(sym).toUpperCase();
    const token = spotPairSymbolToBaseToken(pair);
    if (!token) continue;
    const priceUsd = Number(row.price);
    if (!Number.isFinite(priceUsd) || priceUsd < 0) continue;
    out.push({ pair, token: normalizeOffchainTokenSymbol(token), priceUsd });
  }
  return out;
}

/**
 * @returns {Promise<Array<{ pair: string, token: string, priceUsd: number }>>}
 * Full spot list; **USD-like quoted** instruments only; price from `lastPrice` (or `usdIndexPrice` when present).
 */
export async function fetchBybitSpotUsdLikePrices() {
  const data = await fetchJson(
    "https://api.bybit.com/v5/market/tickers?category=spot",
  );
  const list = data?.result?.list;
  if (!Array.isArray(list)) {
    throw new Error("bybit: expected result.list array");
  }
  const out = [];
  for (const row of list) {
    const sym = row?.symbol;
    if (!sym || !isUsdLikeCexSpotSymbol(sym)) continue;
    const pair = String(sym).toUpperCase();
    const token = spotPairSymbolToBaseToken(pair);
    if (!token) continue;
    const raw =
      row.usdIndexPrice && Number(row.usdIndexPrice) > 0
        ? row.usdIndexPrice
        : row.lastPrice;
    const priceUsd = Number(raw);
    if (!Number.isFinite(priceUsd) || priceUsd < 0) continue;
    out.push({ pair, token: normalizeOffchainTokenSymbol(token), priceUsd });
  }
  return out;
}

const COINGECKO_MARKETS_URL =
  "https://api.coingecko.com/api/v3/coins/markets";

/** Max pages to avoid infinite loops (~250 * maxPage coins). */
export const COINGECKO_MAX_PAGES = 80;

function getCoinGeckoHeaders() {
  const headers = {
    Accept: "application/json",
    "User-Agent":
      "cryprice-backend/1.0 (off-chain prices; contact: dev)",
  };
  const key =
    process.env.COINGECKO_API_KEY ?? process.env.COINGECKO_DEMO_API_KEY;
  if (key && String(key).trim()) {
    headers["x-cg-demo-api-key"] = String(key).trim();
  }
  return headers;
}

/**
 * CoinGecko-only fetch: optional demo API key, retries on 429, rejects non-array bodies.
 */
async function fetchCoinGeckoJson(url, options = {}) {
  const maxAttempts = options.maxAttempts ?? 6;
  for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
    const res = await fetch(url, { headers: getCoinGeckoHeaders() });
    const text = await res.text().catch(() => "");
    let body;
    try {
      body = text ? JSON.parse(text) : null;
    } catch {
      body = text;
    }

    if (res.status === 429 && attempt < maxAttempts) {
      const ra = res.headers.get("retry-after");
      const waitSec = ra ? Number(ra) : Math.min(120, 5 * 2 ** (attempt - 1));
      const waitMs = (Number.isFinite(waitSec) && waitSec > 0 ? waitSec : 30) * 1000;
      console.warn(
        `[offchain] coingecko: HTTP 429, retry ${attempt}/${maxAttempts} in ${Math.round(waitMs / 1000)}s`,
        new Date().toISOString(),
      );
      await delay(waitMs);
      continue;
    }

    if (!res.ok) {
      const msg =
        typeof body === "object" && body !== null
          ? JSON.stringify(body).slice(0, 300)
          : String(body ?? text).slice(0, 300);
      throw new Error(`CoinGecko HTTP ${res.status}: ${msg}`);
    }

    if (!Array.isArray(body)) {
      const errPart =
        typeof body === "object" && body !== null
          ? JSON.stringify(body).slice(0, 300)
          : String(body).slice(0, 300);
      throw new Error(
        `CoinGecko: expected JSON array from /coins/markets, got: ${errPart}`,
      );
    }

    return body;
  }
  throw new Error("CoinGecko: max retries exceeded");
}

/**
 * Maps one /coins/markets page into off-chain rows; counts dropped inputs for observability.
 */
export function mapCoinGeckoMarketsPayloadToRowsWithStats(arr) {
  if (!Array.isArray(arr)) {
    return { rows: [], fetched: 0, dropped: 0 };
  }
  const rows = [];
  let dropped = 0;
  for (const c of arr) {
    const id = c?.id;
    const sym = c?.symbol;
    const raw = c?.current_price;
    if (raw == null || raw === "") {
      dropped++;
      continue;
    }
    const priceUsd = Number(raw);
    if (!id || !sym) {
      dropped++;
      continue;
    }
    if (!Number.isFinite(priceUsd) || priceUsd < 0) {
      dropped++;
      continue;
    }
    rows.push({
      pair: String(id),
      token: normalizeOffchainTokenSymbol(sym),
      priceUsd,
    });
  }
  return { rows, fetched: arr.length, dropped };
}

/**
 * Maps one /coins/markets page (array of coin objects) into off-chain rows.
 * Exported for tests and visibility when debugging empty ingests.
 */
export function mapCoinGeckoMarketsPayloadToRows(arr) {
  return mapCoinGeckoMarketsPayloadToRowsWithStats(arr).rows;
}

/**
 * Single page of USD markets (for pagination + per-page persistence).
 * @returns {Promise<{ page: number, rows: Array<{ pair: string, token: string, priceUsd: number }>, rawFetched: number, dropped: number, normalized: number }>}
 */
export async function fetchCoinGeckoUsdMarketsPage(page, options = {}) {
  const perPage = options.perPage ?? 250;
  const url = `${COINGECKO_MARKETS_URL}?vs_currency=usd&order=market_cap_desc&per_page=${perPage}&page=${page}&sparkline=false&price_change_percentage=24h`;
  let arr;
  try {
    arr = await fetchCoinGeckoJson(url, options);
  } catch (e) {
    console.error(
      `[coingecko] ERROR stage=fetch message=${e?.message || e}`,
      new Date().toISOString(),
    );
    throw e;
  }

  const rawFetched = arr.length;
  if (rawFetched === 0) {
    console.log(`[coingecko] page=${page} fetched=0 (end)`);
  } else {
    console.log(`[coingecko] page=${page} fetched=${rawFetched}`);
  }

  let stats;
  try {
    stats = mapCoinGeckoMarketsPayloadToRowsWithStats(arr);
  } catch (e) {
    console.error(
      `[coingecko] ERROR stage=normalize message=${e?.message || e}`,
      new Date().toISOString(),
    );
    throw e;
  }

  const { rows, dropped } = stats;
  console.log(
    `[coingecko] page=${page} normalized=${rows.length} dropped=${dropped}`,
  );
  if (rows.length === 0 && arr.length > 0) {
    console.warn(
      `[offchain] coingecko: page ${page} had ${arr.length} coins but 0 rows after normalization (skipped null prices / ids)`,
      new Date().toISOString(),
    );
  }

  return {
    page,
    rows,
    rawFetched,
    dropped,
    normalized: rows.length,
  };
}

/**
 * Full pagination in one call (all pages in memory). Prefer per-page persistence in ingestion.
 * @returns {Promise<Array<{ pair: string, token: string, priceUsd: number }>>}
 */
export async function fetchCoinGeckoUsdMarketsAllPages(options = {}) {
  const perPage = options.perPage ?? 250;
  const pauseMs = options.pauseMs ?? 2000;
  const out = [];
  for (let page = 1; page <= COINGECKO_MAX_PAGES; page += 1) {
    const { rows } = await fetchCoinGeckoUsdMarketsPage(page, options);
    if (rows.length === 0) break;
    out.push(...rows);
    if (rows.length < perPage) break;
    await delay(pauseMs);
  }
  return out;
}

export { delay as coinGeckoInterPageDelay };

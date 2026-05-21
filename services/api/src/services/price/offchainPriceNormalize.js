/** Quote assets treated as USD-stable for CEX spot symbols (last price ≈ USD). */
const USD_LIKE_QUOTES = ["USDT", "USDC", "BUSD", "FDUSD", "TUSD", "USDD", "DAI"];

/** DB `source` and ingestion labels (must match CHECK on offchain tables). */
export const OFFCHAIN_SOURCES = Object.freeze({
  BINANCE: "binance",
  BYBIT: "bybit",
  COINGECKO: "coingecko",
});

/**
 * Normalized display symbol for API/DB: uppercase ASCII base ticker (e.g. BTC, ETH).
 */
export function normalizeOffchainTokenSymbol(raw) {
  return String(raw ?? "")
    .trim()
    .toUpperCase();
}

/**
 * Derive base token from a provider spot symbol such as BTCUSDT → BTC.
 * If no known quote suffix matches, returns the whole string uppercased.
 */
export function spotPairSymbolToBaseToken(pairSymbol) {
  const u = String(pairSymbol ?? "")
    .trim()
    .toUpperCase();
  for (const q of USD_LIKE_QUOTES) {
    if (u.endsWith(q) && u.length > q.length) {
      return u.slice(0, -q.length);
    }
  }
  return u;
}

/** Binance/Bybit spot symbols quoted vs USD-like stables (include USDT + USDC pairs). */
export function isUsdLikeCexSpotSymbol(symbol) {
  const u = String(symbol ?? "").trim().toUpperCase();
  return USD_LIKE_QUOTES.some((q) => u.endsWith(q) && u.length > q.length);
}

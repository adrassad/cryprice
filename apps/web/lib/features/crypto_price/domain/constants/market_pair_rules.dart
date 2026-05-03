class MarketPairRules {
  MarketPairRules._();

  /// Stablecoins / fiat-pegged tickers used in pair normalization logic.
  static const Set<String> stableTickers = {
    'USD',
    'USDT',
    'USDC',
    'BUSD',
    'DAI',
    'TUSD',
    'USDP',
    'FDUSD',
    'USDD',
    'GUSD',
    'PYUSD',
    'USDE',
    'CRVUSD',
  };

  /// Canonical CoinGecko slug per symbol (explicit map, no fuzzy matching).
  static const Map<String, String> coingeckoCanonicalSlugBySymbol = {
    'BTC': 'bitcoin',
    'ETH': 'ethereum',
    'WBTC': 'wrapped-bitcoin',
    'WETH': 'weth',
    'USDT': 'tether',
    'USDC': 'usd-coin',
  };
}

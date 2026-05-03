/// How [UserPairQuoteConverter.compute] derived [UserPairConversionResult.amount].
enum UserPairConversionMode {
  cexDirect,
  cexInverse,
  cexCross,

  /// CoinGecko: USD price for slug-matched row; user sells crypto for USD-stable.
  coingeckoDirect,

  /// CoinGecko: inverse vs [coingeckoDirect].
  coingeckoInverse,

  coingeckoCross,

  /// DEX / on-chain: USD unit price of [PriceResult.symbol].
  dexUsdDirect,

  dexUsdInverse,
  dexCross,
}

/// Display-ready conversion for a user pair (count × formula), or absent if unknowable.
class UserPairConversionResult {
  const UserPairConversionResult({
    required this.amount,
    required this.currencyLabel,
    required this.mode,
    this.crossDebugDetail,
  });

  final double amount;
  final String currencyLabel;
  final UserPairConversionMode mode;

  /// Which rows/quotes were used for cross-rate (debug UI only).
  final String? crossDebugDetail;
}

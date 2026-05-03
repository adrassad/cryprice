/// Unified domain model for a single price result row.
/// Free of infrastructure types (no CEX or HTTP clients here).
library;

/// Which API produced this row — drives UI sectioning (CEX vs CRYPRICE on-chain JSON,
/// etc.). Do not infer this from [PriceType] alone.
enum PriceResultOrigin {
  cex,

  /// Parsed rows from `GET /prices/current/onchain/` (DEX / per-network).
  crypriceOnchain,

  /// Parsed rows from `GET /prices/current/offchain/` (not the DEX-by-network block).
  crypriceOffchain,
}

enum PriceType {
  /// Centralized exchange (Binance, Bybit, etc.)
  cex,

  /// Broad market / indexed price (e.g. CoinGecko, aggregated CEX)
  aggregated,

  /// App backend — order-book / CEX-style quotes
  offchain,

  /// App backend — DEX / pool / on-chain derived quotes
  onchain,
}

/// Lifecycle / quality of a price row in the UI.
enum PriceStatus { fresh, stale, fallback, error }

/// One resolved quote for a user query, ready for the presentation layer.
class PriceResult {
  const PriceResult({
    required this.source,
    required this.quoteCurrency,
    required this.priceType,
    required this.status,
    required this.origin,
    this.symbol,
    this.network,
    this.tokenAddress,
    this.price,
    this.errorCode,
    this.updatedAt,
  });

  /// Human-readable source (e.g. "Binance", "Off-chain").
  final String source;

  /// Base / asset symbol when known (e.g. BTC).
  final String? symbol;

  final String? network;
  final String? tokenAddress;

  /// Quote currency in user terms (e.g. usdt, usd, eur), as entered or returned.
  final String quoteCurrency;

  final double? price;
  final String? errorCode;
  final DateTime? updatedAt;
  final PriceType priceType;
  final PriceStatus status;
  final PriceResultOrigin origin;

  bool get hasValue =>
      price != null && errorCode == null && status != PriceStatus.error;

  PriceResult copyWith({
    String? source,
    String? symbol,
    String? network,
    String? tokenAddress,
    String? quoteCurrency,
    double? price,
    String? errorCode,
    DateTime? updatedAt,
    PriceType? priceType,
    PriceStatus? status,
    PriceResultOrigin? origin,
  }) {
    return PriceResult(
      source: source ?? this.source,
      symbol: symbol ?? this.symbol,
      network: network ?? this.network,
      tokenAddress: tokenAddress ?? this.tokenAddress,
      quoteCurrency: quoteCurrency ?? this.quoteCurrency,
      price: price ?? this.price,
      errorCode: errorCode ?? this.errorCode,
      updatedAt: updatedAt ?? this.updatedAt,
      priceType: priceType ?? this.priceType,
      status: status ?? this.status,
      origin: origin ?? this.origin,
    );
  }
}

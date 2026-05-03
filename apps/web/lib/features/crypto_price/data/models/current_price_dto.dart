import 'package:crypto_tracker_app/features/crypto_price/domain/entities/price_result.dart';
import 'package:crypto_tracker_app/features/crypto_price/data/models/parsers/current_price_offchain_parser.dart'
    as offchain_parser;
import 'package:crypto_tracker_app/features/crypto_price/data/models/parsers/current_price_onchain_parser.dart'
    as onchain_parser;

/// One row from the Cryprice backend. Off-chain and on-chain endpoints use
/// [parseOffchainBackendResponse] vs [parseOnchainPerNetworkMap] — different JSON shapes.
/// Parsing is defensive: the backend schema is not versioned in-app; keys may vary.
class CurrentPriceItemDto {
  const CurrentPriceItemDto({
    required this.symbol,
    this.network,
    this.tokenAddress,
    this.quote,
    this.price,
    this.updatedAt,
    this.sourceLabel,
  });

  final String? symbol;
  final String? network;
  final String? tokenAddress;
  final String? quote;
  final double? price;
  final DateTime? updatedAt;
  final String? sourceLabel;

  /// Tolerant extraction from a JSON-like map (e.g. nested pool info).
  static CurrentPriceItemDto? fromDynamic(
    Object? value,
    DateTime? fallbackTime,
  ) {
    if (value is! Map) {
      return null;
    }
    final m = <String, dynamic>{};
    value.forEach((k, v) {
      m[k.toString().toLowerCase()] = v;
    });

    String? s = _str(m, const ['symbol', 'base', 'ticker', 'asset', 'name']);
    s ??= _str(m, ['token_symbol']);

    final net = _str(m, const ['network', 'chain', 'blockchain', 'chain_id']);
    final addr = _str(m, const [
      'address',
      'token_address',
      'contract',
      'contract_address',
    ]);
    final quote = _str(m, const [
      'quote',
      'quote_currency',
      'vs',
      'vs_currency',
      'target',
    ]);

    final numStr =
        m['price'] ??
        m['last'] ??
        m['value'] ??
        m['rate'] ??
        m['px'] ??
        m['price_usd'];
    final price =
        numStr == null
            ? null
            : double.tryParse(
              numStr is num
                  ? numStr.toString()
                  : (numStr is String ? numStr : numStr.toString()),
            );

    final updated =
        _tryParseTime(
          m['updated_at'] ??
              m['timestamp'] ??
              m['time'] ??
              m['ts'] ??
              m['collected_at'],
        ) ??
        fallbackTime;

    return CurrentPriceItemDto(
      symbol: s,
      network: net,
      tokenAddress: addr,
      quote: quote,
      price: price,
      updatedAt: updated,
      sourceLabel: _str(m, const ['source', 'provider', 'venue']),
    );
  }

  /// Off-chain `GET /prices/current/offchain/{symbol}`: map key = venue (e.g. binance),
  /// value = list of quote rows with `token`, `pair`, `price_usd`, `source`, timestamps.
  static CurrentPriceItemDto? fromOffchainVenueQuoteRow(
    String venueKey,
    Map<dynamic, dynamic> raw,
    DateTime fallbackTime,
  ) {
    final m = <String, dynamic>{};
    raw.forEach((k, v) {
      m[k.toString().toLowerCase()] = v;
    });
    final numStr = m['price_usd'] ?? m['price'];
    final price =
        numStr == null
            ? null
            : double.tryParse(
              numStr is num
                  ? numStr.toString()
                  : (numStr is String ? numStr : numStr.toString()),
            );
    if (price == null || price <= 0) {
      return null;
    }
    final sym = _str(m, const ['token', 'symbol', 'base', 'ticker']);
    final pair = _str(m, const ['pair']);
    final src = _str(m, const ['source']) ?? venueKey;
    final updated =
        _tryParseTime(
          m['updated_at'] ?? m['calculated_at'] ?? m['timestamp'] ?? m['ts'],
        ) ??
        fallbackTime;
    return CurrentPriceItemDto(
      symbol: sym,
      network: venueKey,
      tokenAddress: null,
      quote: pair,
      price: price,
      updatedAt: updated,
      sourceLabel: src,
    );
  }

  /// `GET /prices/current/onchain/`: one row per top-level key when the value is
  /// a non-null object with at least [price_usd] (and optional `symbol`, `collected_at`).
  /// [networkKey] is the only source of network id (never read from the inner object).
  /// Null or missing `price_usd` for a value object yields no row.
  static CurrentPriceItemDto? fromOnchainPerNetworkValue(
    String networkKey,
    Object? value,
    DateTime fallbackTime,
  ) {
    if (value == null || value is! Map) {
      return null;
    }
    final m = <String, dynamic>{};
    value.forEach((k, v) {
      m[k.toString().toLowerCase()] = v;
    });
    final numStr = m['price_usd'] ?? m['price'] ?? m['value'];
    final price =
        numStr == null
            ? null
            : double.tryParse(
              numStr is num
                  ? numStr.toString()
                  : (numStr is String ? numStr : numStr.toString()),
            );
    if (price == null || price <= 0) {
      return null;
    }
    var s = _str(m, const ['symbol', 'base', 'ticker']);
    s ??= _str(m, ['token_symbol']);
    final collected =
        _tryParseTime(
          m['collected_at'] ?? m['updated_at'] ?? m['timestamp'] ?? m['ts'],
        ) ??
        fallbackTime;
    return CurrentPriceItemDto(
      symbol: s,
      network: networkKey,
      tokenAddress: _str(m, const ['address', 'token_address']),
      quote: 'usd',
      price: price,
      updatedAt: collected,
    );
  }

  static String? _str(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k] ?? m[k.toLowerCase()];
      if (v == null) {
        continue;
      }
      final t = v.toString().trim();
      if (t.isNotEmpty) {
        return t;
      }
    }
    return null;
  }

  static DateTime? _tryParseTime(Object? o) {
    if (o == null) {
      return null;
    }
    if (o is int) {
      if (o > 1e12) {
        return DateTime.fromMillisecondsSinceEpoch(o);
      }
      if (o > 1e9) {
        return DateTime.fromMillisecondsSinceEpoch(o * 1000);
      }
    }
    if (o is num) {
      return _tryParseTime(o.toInt());
    }
    if (o is String) {
      final dt = DateTime.tryParse(o);
      if (dt != null) {
        return dt;
      }
      final n = int.tryParse(o);
      if (n != null) {
        return _tryParseTime(n);
      }
    }
    return null;
  }
}

List<CurrentPriceItemDto> parseOffchainBackendResponse(
  Object? data, {
  DateTime? now,
}) {
  return offchain_parser.parseOffchainBackendResponseImpl(data, now: now);
}

List<CurrentPriceItemDto> parseOnchainPerNetworkMap(
  Object? data, {
  DateTime? now,
}) {
  return onchain_parser.parseOnchainPerNetworkMapImpl(data, now: now);
}

extension CurrentPriceItemDtoX on CurrentPriceItemDto {
  /// Maps a backend row into a [PriceResult] tagged with [origin] (on-chain JSON vs off-chain).
  PriceResult toPriceResult(
    String fromUser,
    String quoteFromUser, {
    required PriceType priceType,
    required PriceResultOrigin origin,
  }) {
    final p = price;
    final sym = (symbol != null && symbol!.isNotEmpty) ? symbol : fromUser;
    // Section routing uses [PriceResultOrigin], not this string. Off-chain rows may carry
    // [sourceLabel] (e.g. exchange id from the API) for display: "CRYPRICE · binance".
    final offSrc = sourceLabel;
    final sourceDisplay = switch (origin) {
      PriceResultOrigin.crypriceOnchain => 'CRYPRICE',
      PriceResultOrigin.crypriceOffchain =>
        (offSrc != null && offSrc.isNotEmpty)
            ? 'CRYPRICE · $offSrc'
            : 'CRYPRICE (off-chain)',
      _ => 'CRYPRICE',
    };
    return PriceResult(
      source: sourceDisplay,
      symbol: sym,
      network: network,
      tokenAddress: tokenAddress,
      quoteCurrency:
          (quote != null && quote!.isNotEmpty) ? quote! : quoteFromUser,
      price: p,
      priceType: priceType,
      status: p != null && p > 0 ? PriceStatus.fresh : PriceStatus.error,
      errorCode: p == null || p <= 0 ? 'error_fetch_failed' : null,
      updatedAt: updatedAt,
      origin: origin,
    );
  }
}

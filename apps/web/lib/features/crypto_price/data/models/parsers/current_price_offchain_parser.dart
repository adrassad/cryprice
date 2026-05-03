import 'package:crypto_tracker_app/features/crypto_price/data/models/current_price_dto.dart';
import 'package:crypto_tracker_app/features/crypto_price/data/models/parsers/current_price_response_parser_common.dart';

/// `GET /prices/current/offchain/{symbol}` only — **not** [parseOnchainPerNetworkMap].
///
/// Primary contract: `{ "binance": [ { "source", "token", "pair", "price_usd", ... } ], "bybit": [ ... ] }`.
/// Fallback: top-level JSON array, `data`/`result` envelopes, or a single aggregate object.
List<CurrentPriceItemDto> parseOffchainBackendResponseImpl(
  Object? data, {
  DateTime? now,
}) {
  final t = now ?? DateTime.now();
  final decoded = decodeJsonObjectIfNeeded(data);
  if (decoded == null) {
    return const [];
  }
  if (decoded is Map) {
    final m = Map<dynamic, dynamic>.from(decoded);
    if (isOnchainErrorOnlyEnvelope(m)) {
      return const [];
    }
    if (_isOffchainVenueListMap(m)) {
      return _parseOffchainVenueListMap(m, t);
    }
  }
  if (decoded is List) {
    final out = <CurrentPriceItemDto>[];
    for (final e in decoded) {
      if (e is Map) {
        final dto = CurrentPriceItemDto.fromDynamic(
          Map<dynamic, dynamic>.from(e),
          t,
        );
        if (dto != null) {
          out.add(dto);
        }
      }
    }
    return out;
  }
  if (decoded is! Map) {
    return const [];
  }
  var m = Map<dynamic, dynamic>.from(decoded);
  final lower = <String, dynamic>{};
  m.forEach((k, v) {
    lower[k.toString().toLowerCase()] = v;
  });
  for (final key in const [
    'data',
    'items',
    'results',
    'prices',
    'rows',
    'providers',
    'sources',
  ]) {
    final v = lower[key];
    if (v is List) {
      return parseOffchainBackendResponseImpl(v, now: t);
    }
  }
  for (final key in const ['data', 'result', 'payload']) {
    final v = lower[key];
    if (v is Map) {
      return parseOffchainBackendResponseImpl(v, now: t);
    }
  }
  final one = CurrentPriceItemDto.fromDynamic(m, t);
  if (one == null) {
    return const [];
  }
  if (one.price != null && one.price! > 0) {
    return [one];
  }
  if (one.symbol != null && one.symbol!.isNotEmpty) {
    return [one];
  }
  return const [];
}

/// True when the body matches the off-chain API: venue name → list of row objects.
bool _isOffchainVenueListMap(Map<dynamic, dynamic> m) {
  if (m.isEmpty) {
    return false;
  }
  var sawList = false;
  for (final e in m.entries) {
    final v = e.value;
    if (v == null) {
      continue;
    }
    if (v is! List) {
      return false;
    }
    sawList = true;
    for (final item in v) {
      if (item != null && item is! Map) {
        return false;
      }
    }
  }
  return sawList;
}

List<CurrentPriceItemDto> _parseOffchainVenueListMap(
  Map<dynamic, dynamic> m,
  DateTime t,
) {
  final out = <CurrentPriceItemDto>[];
  for (final e in m.entries) {
    final venueKey = e.key.toString();
    final v = e.value;
    if (v is! List) {
      continue;
    }
    for (final row in v) {
      if (row is! Map) {
        continue;
      }
      final dto = CurrentPriceItemDto.fromOffchainVenueQuoteRow(
        venueKey,
        Map<dynamic, dynamic>.from(row),
        t,
      );
      if (dto != null) {
        out.add(dto);
      }
    }
  }
  return out;
}

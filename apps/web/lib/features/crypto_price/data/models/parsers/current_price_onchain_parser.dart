import 'package:crypto_tracker_app/features/crypto_price/data/models/current_price_dto.dart';
import 'package:crypto_tracker_app/features/crypto_price/data/models/parsers/current_price_response_parser_common.dart';

/// `GET /prices/current/onchain/{symbol}` body: a map of network id → per-network quote or `null`.
/// Each non-null value becomes one DTO; null values are skipped (no card).
///
/// Handles: raw JSON [String] (some Dio/transform configs), and envelopes such as
/// `{"data": { "arbitrum": { ... } }}` so rows are not dropped at [].
List<CurrentPriceItemDto> parseOnchainPerNetworkMapImpl(
  Object? data, {
  DateTime? now,
}) {
  final t = now ?? DateTime.now();
  var decoded = decodeJsonObjectIfNeeded(data);
  if (decoded is Map) {
    final top = Map<dynamic, dynamic>.from(decoded);
    // `{"error":"Price not found"}` (and similar) → empty DEX rows, not a parse failure.
    if (isOnchainErrorOnlyEnvelope(top)) {
      return const [];
    }
  }
  final map = _unwrapOnchainResponseToNetworkMap(decoded);
  if (map == null) {
    return const [];
  }
  final out = <CurrentPriceItemDto>[];
  for (final e in map.entries) {
    final networkKey = e.key.toString();
    final dto = CurrentPriceItemDto.fromOnchainPerNetworkValue(
      networkKey,
      e.value,
      t,
    );
    if (dto != null) {
      out.add(dto);
    }
  }
  return out;
}

/// Strips one or more `data` / `onchain` / `result` envelopes until a map of
/// network keys (values null or { price_usd, ... }) is found.
Map<dynamic, dynamic>? _unwrapOnchainResponseToNetworkMap(
  Object? data, {
  int depth = 0,
}) {
  if (depth > 6) {
    return null;
  }
  if (data is! Map) {
    return null;
  }
  var m = data;
  if (_mapLooksLikeOnchainPerNetworkMap(m)) {
    return m;
  }
  if (m.length == 1) {
    final only = m.entries.first;
    final k = only.key.toString().toLowerCase();
    if (k == 'data' ||
        k == 'result' ||
        k == 'onchain' ||
        k == 'payload' ||
        k == 'body' ||
        k == 'value' ||
        k == 'prices') {
      final inner = only.value;
      if (inner is Map) {
        return _unwrapOnchainResponseToNetworkMap(inner, depth: depth + 1);
      }
    }
  }
  for (final key in const [
    'data',
    'onchain',
    'result',
    'prices',
    'value',
    'payload',
  ]) {
    final v = m[key] ?? m[key.toString()];
    if (v is Map) {
      final u = _unwrapOnchainResponseToNetworkMap(v, depth: depth + 1);
      if (u != null) {
        return u;
      }
    }
  }
  return m;
}

/// True if map keys are network slugs and values are null or per-network price objects.
bool _mapLooksLikeOnchainPerNetworkMap(Map<dynamic, dynamic> m) {
  if (m.isEmpty) {
    return false;
  }
  var sawPrice = 0;
  for (final e in m.entries) {
    final v = e.value;
    if (v == null) {
      continue;
    }
    if (v is! Map) {
      return false;
    }
    final o = v;
    final low = <String, dynamic>{};
    o.forEach((k, val) {
      low[k.toString().toLowerCase()] = val;
    });
    if (low['price_usd'] != null || low['price'] != null) {
      sawPrice++;
    } else {
      return false;
    }
  }
  return sawPrice > 0;
}

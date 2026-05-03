import 'dart:convert';

/// True when the body is an API error object, not a network-keyed price map.
bool isOnchainErrorOnlyEnvelope(Map<dynamic, dynamic> m) {
  if (m.isEmpty) {
    return false;
  }
  if (m.length == 1) {
    final k = m.keys.first.toString().toLowerCase();
    return k == 'error';
  }
  // e.g. `{ "error": "...", "code": 404 }` — no network entries
  if (!m.containsKey('error')) {
    return false;
  }
  for (final e in m.entries) {
    final key = e.key.toString().toLowerCase();
    if (key == 'error' ||
        key == 'message' ||
        key == 'code' ||
        key == 'status') {
      continue;
    }
    final v = e.value;
    if (v is Map) {
      final low = <String, dynamic>{};
      v.forEach((k, val) {
        low[k.toString().toLowerCase()] = val;
      });
      if (low['price_usd'] != null || low['price'] != null) {
        return false;
      }
    }
  }
  return true;
}

Object? decodeJsonObjectIfNeeded(Object? data) {
  if (data is String) {
    final s = data.trim();
    if (s.isEmpty) {
      return null;
    }
    try {
      return jsonDecode(s);
    } catch (_) {
      return null;
    }
  }
  return data;
}

Map<String, Object?> hfMapValue(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return value.cast<String, Object?>();
  }
  return const <String, Object?>{};
}

Map<String, Object?>? hfNullableMapValue(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return value.cast<String, Object?>();
  }
  return null;
}

List<Map<String, Object?>> hfListValue(Object? value) {
  if (value is! List) {
    return const <Map<String, Object?>>[];
  }
  return value
      .whereType<Map>()
      .map((item) => item.cast<String, Object?>())
      .toList(growable: false);
}

String hfStringValue(Object? value) => value?.toString() ?? '';

String? hfNullableStringValue(Object? value) {
  if (value == null) {
    return null;
  }
  final s = value.toString().trim();
  if (s.isEmpty) {
    return null;
  }
  return s;
}

/// Stable string id when backend sends int or string (e.g. asset id `"10"`).
String hfIdStringValue(Object? value) => value?.toString() ?? '';

String? hfNullableIdStringValue(Object? value) => hfNullableStringValue(value);

int hfIntValue(Object? value) => hfNullableIntValue(value) ?? 0;

int? hfNullableIntValue(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim());
  }
  return null;
}

bool hfBoolValue(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is String) {
    return value.toLowerCase() == 'true';
  }
  return false;
}

String? hfNullableLogoUrl(Object? value) {
  final trimmed = hfNullableStringValue(value);
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

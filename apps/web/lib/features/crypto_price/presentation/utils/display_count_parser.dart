/// Parses the Count field for multiplying displayed amounts: unit price × count.
///
/// - Empty input → [fallbackOnInvalid] (default `1.0`).
/// - Invalid / non-finite → [fallbackOnInvalid].
/// - Negative values → `0.0`.
/// - Supports `,` as decimal separator when `.` is absent; basic `1.234,56` /
///   `1,234.56` handling when both appear.
double parseDisplayCount(
  String raw, {
  double fallbackOnInvalid = 1.0,
}) {
  var s = raw.trim();
  if (s.isEmpty) {
    return fallbackOnInvalid;
  }
  s = s.replaceAll(RegExp(r'\s'), '');
  if (s.contains(',') && !s.contains('.')) {
    s = s.replaceAll(',', '.');
  } else if (s.contains(',') && s.contains('.')) {
    final lastComma = s.lastIndexOf(',');
    final lastDot = s.lastIndexOf('.');
    if (lastComma > lastDot) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else {
      s = s.replaceAll(',', '');
    }
  }
  final v = double.tryParse(s);
  if (v == null || !v.isFinite) {
    return fallbackOnInvalid;
  }
  if (v < 0) {
    return 0.0;
  }
  return v;
}

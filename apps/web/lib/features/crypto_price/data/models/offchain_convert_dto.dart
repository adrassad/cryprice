import 'package:cryprice_frontend/features/crypto_price/domain/entities/offchain_convert_result.dart';

class OffchainConvertDto {
  const OffchainConvertDto({
    required this.coin1,
    required this.coin2,
    required this.count,
    this.binance,
    this.bybit,
  });

  final String coin1;
  final String coin2;
  final double count;
  final OffchainVenueConvert? binance;
  final OffchainVenueConvert? bybit;

  static OffchainConvertDto? fromDynamic(Object? data) {
    if (data is! Map) {
      return null;
    }
    final m = <String, dynamic>{};
    data.forEach((k, v) {
      m[k.toString().toLowerCase()] = v;
    });

    final coin1 = _str(m['coin1']);
    final coin2 = _str(m['coin2']);
    final count = _num(m['count']);
    if (coin1 == null || coin2 == null || count == null || count <= 0) {
      return null;
    }

    return OffchainConvertDto(
      coin1: coin1,
      coin2: coin2,
      count: count,
      binance: _venue(m['binance']),
      bybit: _venue(m['bybit']),
    );
  }

  OffchainConvertResult toEntity() {
    return OffchainConvertResult(
      coin1: coin1,
      coin2: coin2,
      count: count,
      binance: binance,
      bybit: bybit,
    );
  }

  static OffchainVenueConvert? _venue(Object? raw) {
    if (raw == null) {
      return null;
    }
    if (raw is! Map) {
      return null;
    }
    final m = <String, dynamic>{};
    raw.forEach((k, v) {
      m[k.toString().toLowerCase()] = v;
    });
    final sum = _num(m['sum']);
    if (sum == null) {
      return null;
    }
    return OffchainVenueConvert(
      sum: sum,
      collected: _parseTime(m['collected']),
    );
  }

  static String? _str(Object? v) {
    if (v == null) {
      return null;
    }
    final s = v.toString().trim();
    return s.isEmpty ? null : s.toUpperCase();
  }

  static double? _num(Object? v) {
    if (v == null) {
      return null;
    }
    if (v is num) {
      final d = v.toDouble();
      return d.isFinite ? d : null;
    }
    final d = double.tryParse(v.toString().trim());
    if (d == null || !d.isFinite) {
      return null;
    }
    return d;
  }

  static DateTime? _parseTime(Object? v) {
    if (v == null) {
      return null;
    }
    final s = v.toString().trim();
    if (s.isEmpty) {
      return null;
    }
    return DateTime.tryParse(s);
  }
}

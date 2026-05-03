import 'package:crypto_tracker_app/features/crypto_price/domain/conversion/user_pair_conversion_result.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/conversion/user_pair_quote_converter.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/entities/price_result.dart';

/// One repository row plus precomputed user-pair conversion for UI (display + clipboard).
class PriceRowViewModel {
  const PriceRowViewModel({
    required this.row,
    required this.userConversion,
  });

  final PriceResult row;

  /// Null when the comparison cannot be computed honestly for this row (hide output).
  final UserPairConversionResult? userConversion;
}

/// Builds view models using the same CEX vs DEX section split as the results UI.
class PriceRowDisplayEnricher {
  PriceRowDisplayEnricher._();

  static String _conversionCacheKey({
    required PriceResult row,
    required String userTicker1,
    required String userTicker2,
    required double countMultiplier,
  }) {
    return '${row.origin.name}|${row.priceType.name}|${row.source}|'
        '${row.network ?? ''}|${row.symbol ?? ''}|${row.quoteCurrency}|'
        '${row.tokenAddress ?? ''}|${row.price?.toString() ?? 'null'}|'
        '$userTicker1|$userTicker2|$countMultiplier';
  }

  static List<PriceResult> cexSection(List<PriceResult> all) {
    return all
        .where(
          (r) =>
              r.origin == PriceResultOrigin.cex ||
              r.origin == PriceResultOrigin.crypriceOffchain,
        )
        .toList();
  }

  static List<PriceResult> dexSection(List<PriceResult> all) {
    return all
        .where((r) => r.origin == PriceResultOrigin.crypriceOnchain)
        .toList();
  }

  static List<PriceRowViewModel> build({
    required List<PriceResult> results,
    required String userTicker1,
    required String userTicker2,
    required double countMultiplier,
  }) {
    final cex = cexSection(results);
    final dex = dexSection(results);
    final conversionCache = <String, UserPairConversionResult?>{};
    return results.map((row) {
      final section = row.origin == PriceResultOrigin.crypriceOnchain
          ? dex
          : cex;
      final cacheKey = _conversionCacheKey(
        row: row,
        userTicker1: userTicker1,
        userTicker2: userTicker2,
        countMultiplier: countMultiplier,
      );
      final conv = conversionCache.putIfAbsent(
        cacheKey,
        () => UserPairQuoteConverter.compute(
          sectionRows: section,
          anchorRow: row,
          userCoin1: userTicker1,
          userCoin2: userTicker2,
          count: countMultiplier,
        ),
      );
      return PriceRowViewModel(row: row, userConversion: conv);
    }).toList();
  }
}

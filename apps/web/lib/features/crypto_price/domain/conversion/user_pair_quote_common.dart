import 'package:crypto_tracker_app/features/crypto_price/domain/constants/market_pair_rules.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/entities/price_result.dart';

enum PriceRowKind { cexPair, coingecko, dex }

PriceRowKind kindOf(PriceResult r) {
  if (r.origin == PriceResultOrigin.crypriceOnchain) {
    return PriceRowKind.dex;
  }
  final n = (r.network ?? '').toLowerCase().trim();
  if (n == 'coingecko') {
    return PriceRowKind.coingecko;
  }
  if (r.source.toLowerCase().contains('coingecko')) {
    return PriceRowKind.coingecko;
  }
  return PriceRowKind.cexPair;
}

String alnumTicker(String raw) {
  return raw.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

String rowBaseTicker(PriceResult r) {
  return alnumTicker(r.symbol ?? '');
}

String rowQuoteTicker(PriceResult r) {
  final raw = r.quoteCurrency.trim();
  if (raw.isEmpty) {
    return '';
  }
  final lower = raw.toLowerCase();
  if (lower.contains('/')) {
    final parts = lower.split('/');
    if (parts.length >= 2) {
      return alnumTicker(parts[1]);
    }
  }
  final base = rowBaseTicker(r);
  final q = alnumTicker(raw);
  if (base.isNotEmpty && q.startsWith(base) && q.length > base.length) {
    return q.substring(base.length);
  }
  return q;
}

bool isUsdLikeUserTicker(String raw) {
  return MarketPairRules.stableTickers.contains(raw.trim().toUpperCase());
}

bool bothUserAssetsNonStable(String userCoin1, String userCoin2) {
  return !isUsdLikeUserTicker(userCoin1) && !isUsdLikeUserTicker(userCoin2);
}

bool validPrice(double? p) => p != null && p.isFinite && p > 0;

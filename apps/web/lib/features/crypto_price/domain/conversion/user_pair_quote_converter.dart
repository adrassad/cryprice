import 'package:crypto_tracker_app/features/crypto_price/domain/conversion/user_pair_conversion_result.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/conversion/user_pair_quote_common.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/constants/market_pair_rules.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/entities/price_result.dart';

const List<String> _cexCrossQuotePriority = [
  'usdt',
  'usdc',
  'fdusd',
  'busd',
  'tusd',
  'dai',
];

// --- CEX pair strategy ---

PriceResult? _cexRowForBaseQuoteVenueSource(
  List<PriceResult> rows,
  String venueLower,
  String providerSource,
  String baseAlnum,
  String quoteAlnum,
) {
  for (final r in rows) {
    if (kindOf(r) != PriceRowKind.cexPair) {
      continue;
    }
    if ((r.network ?? '').toLowerCase().trim() != venueLower) {
      continue;
    }
    if (r.source.trim() != providerSource) {
      continue;
    }
    if (rowBaseTicker(r) != baseAlnum) {
      continue;
    }
    if (rowQuoteTicker(r) != quoteAlnum) {
      continue;
    }
    if (validPrice(r.price)) {
      return r;
    }
  }
  return null;
}

UserPairConversionResult? _tryCexCross({
  required List<PriceResult> sectionRows,
  required PriceResult anchorRow,
  required String userCoin1,
  required String userCoin2,
  required double count,
}) {
  if (kindOf(anchorRow) != PriceRowKind.cexPair) {
    return null;
  }
  final venue = (anchorRow.network ?? '').toLowerCase().trim();
  final providerSource = anchorRow.source.trim();
  if (venue.isEmpty || providerSource.isEmpty) {
    return null;
  }
  final u1 = alnumTicker(userCoin1);
  final u2 = alnumTicker(userCoin2);
  final label = userCoin2.trim().toUpperCase();

  for (final q in _cexCrossQuotePriority) {
    final r1 = _cexRowForBaseQuoteVenueSource(
      sectionRows,
      venue,
      providerSource,
      u1,
      q,
    );
    final r2 = _cexRowForBaseQuoteVenueSource(
      sectionRows,
      venue,
      providerSource,
      u2,
      q,
    );
    final p1 = r1?.price;
    final p2 = r2?.price;
    if (p1 != null && p2 != null && p2 > 0) {
      final amount = count * p1 / p2;
      final detail =
          'cexCross venue=$venue source=$providerSource quote=$q '
          'p1=$p1(${r1!.symbol}) p2=$p2(${r2!.symbol}) formula=count×p1/p2';
      return UserPairConversionResult(
        amount: amount,
        currencyLabel: label,
        mode: UserPairConversionMode.cexCross,
        crossDebugDetail: detail,
      );
    }
  }
  return null;
}

UserPairConversionResult? _cexSingleRow({
  required PriceResult r,
  required String userCoin1,
  required String userCoin2,
  required double count,
  required double unit,
}) {
  final base = rowBaseTicker(r);
  final quote = rowQuoteTicker(r);
  final u1 = alnumTicker(userCoin1);
  final u2 = alnumTicker(userCoin2);
  final label = userCoin2.trim().toUpperCase();

  if (base.isEmpty || quote.isEmpty || u1.isEmpty || u2.isEmpty) {
    return null;
  }
  if (u1 == base && u2 == quote) {
    return UserPairConversionResult(
      amount: count * unit,
      currencyLabel: label,
      mode: UserPairConversionMode.cexDirect,
    );
  }
  if (u1 == quote && u2 == base) {
    return UserPairConversionResult(
      amount: count / unit,
      currencyLabel: label,
      mode: UserPairConversionMode.cexInverse,
    );
  }
  return null;
}

// --- CoinGecko strategy (slug in [PriceResult.quoteCurrency], not a trading pair) ---

PriceResult? _coingeckoRowForUserSymbol(
  List<PriceResult> rows,
  String symbolUpper,
) {
  final slug = MarketPairRules.coingeckoCanonicalSlugBySymbol[
    symbolUpper.trim().toUpperCase()
  ];
  if (slug == null) {
    return null;
  }
  for (final r in rows) {
    if (kindOf(r) != PriceRowKind.coingecko) {
      continue;
    }
    if (r.quoteCurrency.trim().toLowerCase() != slug) {
      continue;
    }
    if (validPrice(r.price)) {
      return r;
    }
  }
  return null;
}

UserPairConversionResult? _tryCoingeckoCross({
  required List<PriceResult> sectionRows,
  required String userCoin1,
  required String userCoin2,
  required double count,
}) {
  final k1 = userCoin1.trim().toUpperCase();
  final k2 = userCoin2.trim().toUpperCase();
  final r1 = _coingeckoRowForUserSymbol(sectionRows, k1);
  final r2 = _coingeckoRowForUserSymbol(sectionRows, k2);
  final p1 = r1?.price;
  final p2 = r2?.price;
  if (p1 == null || p2 == null || p2 <= 0) {
    return null;
  }
  final amount = count * p1 / p2;
  final label = userCoin2.trim().toUpperCase();
  final detail =
      'coingeckoCross slug1=${r1!.quoteCurrency} p1=$p1 slug2=${r2!.quoteCurrency} p2=$p2 '
      'formula=count×p1/p2';
  return UserPairConversionResult(
    amount: amount,
    currencyLabel: label,
    mode: UserPairConversionMode.coingeckoCross,
    crossDebugDetail: detail,
  );
}

UserPairConversionResult? _coingeckoSingleRow({
  required PriceResult r,
  required String userCoin1,
  required String userCoin2,
  required double count,
  required double unit,
}) {
  final slugRow = r.quoteCurrency.trim().toLowerCase();
  final mappedSlug = MarketPairRules.coingeckoCanonicalSlugBySymbol[
    (r.symbol ?? '').trim().toUpperCase()
  ];
  if (mappedSlug == null || mappedSlug != slugRow) {
    return null;
  }
  final base = rowBaseTicker(r);
  final u1 = alnumTicker(userCoin1);
  final u2 = alnumTicker(userCoin2);
  final label = userCoin2.trim().toUpperCase();

  if (base.isEmpty || u1.isEmpty || u2.isEmpty) {
    return null;
  }

  final u1Usd = isUsdLikeUserTicker(userCoin1);
  final u2Usd = isUsdLikeUserTicker(userCoin2);

  if (u1 == base && u2Usd) {
    return UserPairConversionResult(
      amount: count * unit,
      currencyLabel: label,
      mode: UserPairConversionMode.coingeckoDirect,
    );
  }
  if (u1Usd && u2 == base) {
    return UserPairConversionResult(
      amount: count / unit,
      currencyLabel: label,
      mode: UserPairConversionMode.coingeckoInverse,
    );
  }
  return null;
}

// --- DEX / on-chain USD strategy ---

PriceResult? _dexRowForNetworkAndBase(
  List<PriceResult> rows,
  String networkLower,
  String baseAlnum,
) {
  for (final r in rows) {
    if (kindOf(r) != PriceRowKind.dex) {
      continue;
    }
    if ((r.network ?? '').toLowerCase().trim() != networkLower) {
      continue;
    }
    if (rowBaseTicker(r) != baseAlnum) {
      continue;
    }
    if (validPrice(r.price)) {
      return r;
    }
  }
  return null;
}

UserPairConversionResult? _tryDexCross({
  required List<PriceResult> sectionRows,
  required PriceResult anchorRow,
  required String userCoin1,
  required String userCoin2,
  required double count,
}) {
  if (kindOf(anchorRow) != PriceRowKind.dex) {
    return null;
  }
  final net = (anchorRow.network ?? '').toLowerCase().trim();
  if (net.isEmpty) {
    return null;
  }
  final u1 = alnumTicker(userCoin1);
  final u2 = alnumTicker(userCoin2);
  final r1 = _dexRowForNetworkAndBase(sectionRows, net, u1);
  final r2 = _dexRowForNetworkAndBase(sectionRows, net, u2);
  final p1 = r1?.price;
  final p2 = r2?.price;
  if (p1 == null || p2 == null || p2 <= 0) {
    return null;
  }
  final amount = count * p1 / p2;
  final label = userCoin2.trim().toUpperCase();
  final detail =
      'dexCross network=$net p1=$p1(${r1!.symbol}) p2=$p2(${r2!.symbol}) formula=count×p1/p2';
  return UserPairConversionResult(
    amount: amount,
    currencyLabel: label,
    mode: UserPairConversionMode.dexCross,
    crossDebugDetail: detail,
  );
}

UserPairConversionResult? _dexSingleRow({
  required PriceResult r,
  required String userCoin1,
  required String userCoin2,
  required double count,
  required double unit,
}) {
  final base = rowBaseTicker(r);
  final u1 = alnumTicker(userCoin1);
  final u2 = alnumTicker(userCoin2);
  final label = userCoin2.trim().toUpperCase();

  if (base.isEmpty || u1.isEmpty || u2.isEmpty) {
    return null;
  }

  final u1Usd = isUsdLikeUserTicker(userCoin1);
  final u2Usd = isUsdLikeUserTicker(userCoin2);

  if (u1 == base && u2Usd) {
    return UserPairConversionResult(
      amount: count * unit,
      currencyLabel: label,
      mode: UserPairConversionMode.dexUsdDirect,
    );
  }
  if (u1Usd && u2 == base) {
    return UserPairConversionResult(
      amount: count / unit,
      currencyLabel: label,
      mode: UserPairConversionMode.dexUsdInverse,
    );
  }
  return null;
}

/// Provider-aware user-pair quote math: direct, inverse, cross, or absent (no guessing).
class UserPairQuoteConverter {
  UserPairQuoteConverter._();

  /// Full computation for one [anchorRow] using all rows in its UI section ([sectionRows]).
  static UserPairConversionResult? compute({
    required List<PriceResult> sectionRows,
    required PriceResult anchorRow,
    required String userCoin1,
    required String userCoin2,
    required double count,
  }) {
    if (count.isNaN || !count.isFinite) {
      return null;
    }

    final unit = anchorRow.price;
    if (!validPrice(unit)) {
      return null;
    }

    final kind = kindOf(anchorRow);
    final bothNonStable = bothUserAssetsNonStable(userCoin1, userCoin2);

    if (bothNonStable) {
      switch (kind) {
        case PriceRowKind.coingecko:
          return _tryCoingeckoCross(
            sectionRows: sectionRows,
            userCoin1: userCoin1,
            userCoin2: userCoin2,
            count: count,
          );
        case PriceRowKind.dex:
          return _tryDexCross(
            sectionRows: sectionRows,
            anchorRow: anchorRow,
            userCoin1: userCoin1,
            userCoin2: userCoin2,
            count: count,
          );
        case PriceRowKind.cexPair:
          final cross = _tryCexCross(
            sectionRows: sectionRows,
            anchorRow: anchorRow,
            userCoin1: userCoin1,
            userCoin2: userCoin2,
            count: count,
          );
          return cross;
      }
    }

    switch (kind) {
      case PriceRowKind.cexPair:
        return _cexSingleRow(
          r: anchorRow,
          userCoin1: userCoin1,
          userCoin2: userCoin2,
          count: count,
          unit: unit!,
        );
      case PriceRowKind.coingecko:
        return _coingeckoSingleRow(
          r: anchorRow,
          userCoin1: userCoin1,
          userCoin2: userCoin2,
          count: count,
          unit: unit!,
        );
      case PriceRowKind.dex:
        return _dexSingleRow(
          r: anchorRow,
          userCoin1: userCoin1,
          userCoin2: userCoin2,
          count: count,
          unit: unit!,
        );
    }
  }
}

/// For presentation/debug: how a row is classified for conversion.
String conversionProviderKind(PriceResult r) {
  switch (kindOf(r)) {
    case PriceRowKind.dex:
      return 'dex_onchain_usd';
    case PriceRowKind.coingecko:
      return 'coingecko_usd';
    case PriceRowKind.cexPair:
      return 'cex_pair';
  }
}

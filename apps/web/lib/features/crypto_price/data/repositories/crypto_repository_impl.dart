import 'package:crypto_tracker_app/features/crypto_price/data/datasources/backend/offchain_onchain_prices_client.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/constants/market_pair_rules.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/entities/price_fetch_outcome.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/repositories/crypto_repository.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/entities/price_result.dart';
import 'package:flutter/foundation.dart';

class CryptoRepositoryImpl implements CryptoRepository {
  CryptoRepositoryImpl({
    required OffchainOnchainPricesClient backend,
  }) : _backend = backend;

  final OffchainOnchainPricesClient _backend;

  @override
  Future<PriceFetchOutcome> getAllPrices(
    String ticker1,
    String ticker2,
    String count,
  ) async {
    final t1 = ticker1.trim();
    final t2 = ticker2.trim();

    // Backend paths are `/offchain/{asset}` and `/onchain/{asset}` for the priced
    // **base** coin (e.g. BTC), not the stable side. Using Coin1 alone breaks
    // USDT→BTC (was calling `/offchain/usdt` and never loading BTC/USDT rows).
    final bothNonStablePair = _bothNonStableAssets(t1, t2);
    late final List<PriceResult> offRows;
    late final List<PriceResult> onRows;
    late final BackendPathTrace offTrace;
    late final BackendPathTrace onTrace;

    if (bothNonStablePair) {
      final qh1 = _mapperQuoteHint(t1, t2, t1);
      final qh2 = _mapperQuoteHint(t1, t2, t2);
      if (kDebugMode) {
        debugPrint(
          '[cryprice] userPair=$t1/$t2 dualPath off+on (cross-rate) qh1=$qh1 qh2=$qh2',
        );
      }
      final off1 = _backend.fetchOffchainTraced(t1, qh1, count);
      final off2 = _backend.fetchOffchainTraced(t2, qh2, count);
      final on1 = _backend.fetchOnchainTraced(t1, qh1, count);
      final on2 = _backend.fetchOnchainTraced(t2, qh2, count);
      final batched = await Future.wait<TracedPriceRows>([off1, off2, on1, on2]);
      offTrace = _mergeOffchainTraces(batched[0].trace, batched[1].trace);
      onTrace = _mergeOnchainTraces(batched[2].trace, batched[3].trace);
      offRows = [
        ...batched[0].results.map((r) => _ensureSymbol(r, t1)),
        ...batched[1].results.map((r) => _ensureSymbol(r, t2)),
      ];
      onRows = [
        ...batched[2].results.map((r) => _ensureSymbol(r, t1)),
        ...batched[3].results.map((r) => _ensureSymbol(r, t2)),
      ];
    } else {
      final pathAsset = _backendPathAssetForCryprice(t1, t2);
      final quoteHint = _mapperQuoteHint(t1, t2, pathAsset);
      if (kDebugMode) {
        debugPrint(
          '[cryprice] userPair=$t1/$t2 pathAsset=$pathAsset quoteHint=$quoteHint',
        );
      }
      final offF = _backend.fetchOffchainTraced(pathAsset, quoteHint, count);
      final onF = _backend.fetchOnchainTraced(pathAsset, quoteHint, count);
      final batched = await Future.wait<TracedPriceRows>([offF, onF]);
      offTrace = batched[0].trace;
      onTrace = batched[1].trace;
      offRows = batched[0].results.map((r) => _ensureSymbol(r, pathAsset)).toList();
      onRows = batched[1].results.map((r) => _ensureSymbol(r, pathAsset)).toList();
    }

    final merged = <PriceResult>[];
    // Order: off-chain backend index (CEX UI section), then on-chain DEX networks.
    merged
      ..addAll(offRows)
      ..addAll(onRows);

    // Dual base-asset fetches (e.g. BTC + WBTC) often return the same CEX row from
    // both HTTP responses — duplicate list items break Flutter ValueKeys in the UI.
    final dedupedMerged = _dedupePriceResultsPreservingOrder(merged);

    final mergedForUi = dedupedMerged.where((r) {
      final isCexSectionRow =
          r.origin == PriceResultOrigin.crypriceOffchain ||
          r.origin == PriceResultOrigin.cex;
      return !isCexSectionRow || _cexRowMatchesUserPair(r, t1, t2);
    }).toList();

    final debug = PriceFetchDebugSnapshot(
      onchainTrace: onTrace,
      offchainTrace: offTrace,
      mergedRowOrigins: mergedForUi.map((r) => r.origin.name).toList(),
      repositoryTotalRows: mergedForUi.length,
      cexCountAfterGroup: mergedForUi
          .where(
            (r) =>
                r.origin == PriceResultOrigin.cex ||
                r.origin == PriceResultOrigin.crypriceOffchain,
          )
          .length,
      dexCountAfterGroup: mergedForUi
          .where((r) => r.origin == PriceResultOrigin.crypriceOnchain)
          .length,
    );

    // Empty merge still returns outcome + debug snapshot (console in kDebugMode only).
    return PriceFetchOutcome(
      results: mergedForUi,
      debug: debug,
    );
  }

  PriceResult _ensureSymbol(PriceResult r, String pathAsset) {
    if (r.symbol == null || r.symbol!.isEmpty) {
      return r.copyWith(symbol: pathAsset);
    }
    return r;
  }

  /// One stable id per logical quote row (used after merging multi-fetch results).
  static String _logicalPriceRowKey(PriceResult r) {
    final net = (r.network ?? '').trim();
    final addr = (r.tokenAddress ?? '').trim().toLowerCase();
    final sym = (r.symbol ?? '').trim();
    final qc = r.quoteCurrency.trim();
    final src = r.source.trim();
    return '${r.origin.name}|${r.priceType.name}|$src|$net|$sym|$qc|$addr';
  }

  static List<PriceResult> _dedupePriceResultsPreservingOrder(
    List<PriceResult> rows,
  ) {
    final seen = <String>{};
    final out = <PriceResult>[];
    for (final r in rows) {
      if (seen.add(_logicalPriceRowKey(r))) {
        out.add(r);
      }
    }
    return out;
  }

  static String _backendPathAssetForCryprice(String t1, String t2) {
    final a = t1.trim().toUpperCase();
    final b = t2.trim().toUpperCase();
    final aSt = MarketPairRules.stableTickers.contains(a);
    final bSt = MarketPairRules.stableTickers.contains(b);
    if (aSt && !bSt) {
      return t2.trim();
    }
    if (bSt && !aSt) {
      return t1.trim();
    }
    return t1.trim();
  }

  /// Second argument to DTO `toPriceResult` when quote field is empty.
  static String _mapperQuoteHint(String t1, String t2, String pathAsset) {
    final p = pathAsset.trim().toUpperCase();
    if (t1.trim().toUpperCase() == p) {
      return t2.trim();
    }
    return t1.trim();
  }

  static bool _bothNonStableAssets(String t1, String t2) {
    final a = t1.trim().toUpperCase();
    final b = t2.trim().toUpperCase();
    return !MarketPairRules.stableTickers.contains(a) &&
        !MarketPairRules.stableTickers.contains(b);
  }

  static const Set<String> _crossMarketQuoteLegs = {
    'usdt',
    'usdc',
    'fdusd',
    'busd',
    'tusd',
    'dai',
  };

  /// Quote leg for CEX rows (matches [rowQuoteTicker] in presentation).
  static String _rowQuoteLegForFilter(PriceResult r) {
    final raw = r.quoteCurrency.trim();
    if (raw.isEmpty) {
      return '';
    }
    final lower = raw.toLowerCase();
    if (lower.contains('/')) {
      final parts = lower.split('/');
      if (parts.length >= 2) {
        return _cexAlnumTicker(parts[1]);
      }
    }
    final s = _cexAlnumTicker(r.symbol ?? '');
    final q = _cexAlnumTicker(raw);
    if (s.isNotEmpty && q.startsWith(s) && q.length > s.length) {
      return q.substring(s.length);
    }
    return q;
  }

  static bool _cexRowMatchesCrossCryptoPair(
    PriceResult r,
    String ticker1,
    String ticker2,
  ) {
    final b = _cexAlnumTicker(r.symbol ?? '');
    final c1 = _cexAlnumTicker(ticker1);
    final c2 = _cexAlnumTicker(ticker2);
    if (b != c1 && b != c2) {
      return false;
    }
    final q = _rowQuoteLegForFilter(r);
    return _crossMarketQuoteLegs.contains(q);
  }

  static BackendPathTrace _mergeOffchainTraces(
    BackendPathTrace a,
    BackendPathTrace b,
  ) {
    return BackendPathTrace(
      path: '${a.path} ; ${b.path}',
      isOnchainEndpoint: false,
      resolvedBaseUrl:
          a.resolvedBaseUrl.isNotEmpty ? a.resolvedBaseUrl : b.resolvedBaseUrl,
      fullRequestUrl: '${a.fullRequestUrl} | ${b.fullRequestUrl}',
      httpAttempted: a.httpAttempted || b.httpAttempted,
      statusCode: b.statusCode ?? a.statusCode,
      rawDataRuntimeType: '${a.rawDataRuntimeType}+${b.rawDataRuntimeType}',
      rawDataPreview: 'A:${a.rawDataPreview} B:${b.rawDataPreview}',
      parsedDtoCount: a.parsedDtoCount + b.parsedDtoCount,
      mappedResultCount: a.mappedResultCount + b.mappedResultCount,
      networkKeys: [...a.networkKeys, ...b.networkKeys],
      rowOriginNames: [...a.rowOriginNames, ...b.rowOriginNames],
      error: a.error ?? b.error,
    );
  }

  static BackendPathTrace _mergeOnchainTraces(
    BackendPathTrace a,
    BackendPathTrace b,
  ) {
    return BackendPathTrace(
      path: '${a.path} ; ${b.path}',
      isOnchainEndpoint: true,
      resolvedBaseUrl:
          a.resolvedBaseUrl.isNotEmpty ? a.resolvedBaseUrl : b.resolvedBaseUrl,
      fullRequestUrl: '${a.fullRequestUrl} | ${b.fullRequestUrl}',
      httpAttempted: a.httpAttempted || b.httpAttempted,
      statusCode: b.statusCode ?? a.statusCode,
      rawDataRuntimeType: '${a.rawDataRuntimeType}+${b.rawDataRuntimeType}',
      rawDataPreview: 'A:${a.rawDataPreview} B:${b.rawDataPreview}',
      parsedDtoCount: a.parsedDtoCount + b.parsedDtoCount,
      mappedResultCount: a.mappedResultCount + b.mappedResultCount,
      networkKeys: [...a.networkKeys, ...b.networkKeys],
      rowOriginNames: [...a.rowOriginNames, ...b.rowOriginNames],
      error: a.error ?? b.error,
    );
  }

  /// Lowercase pair id with only [a-z0-9] (e.g. `btcusdt`, `btcusdt` from `BTC/USDT`).
  static String _cexAlnumTicker(String raw) {
    return raw.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  /// Single id for "base+quote" matching, aligned with how off-chain rows store
  /// either a full market id in [PriceResult.quoteCurrency] (e.g. BTCUSDT) or a
  /// quote-only ticker (e.g. USDT) with base in [PriceResult.symbol].
  static String? _cexConcatPairId(PriceResult r, String userBaseTicker) {
    final s = _cexAlnumTicker(
      (r.symbol != null && r.symbol!.trim().isNotEmpty)
          ? r.symbol!.trim()
          : userBaseTicker.trim(),
    );
    final qRaw = r.quoteCurrency.trim();
    if (qRaw.isEmpty) {
      return s.isEmpty ? null : s;
    }
    final qLower = qRaw.toLowerCase().replaceAll(RegExp(r'\s'), '');
    if (qLower.contains('/')) {
      final parts = qLower.split('/');
      if (parts.length >= 2) {
        return _cexAlnumTicker(parts[0]) + _cexAlnumTicker(parts[1]);
      }
    }
    final q = _cexAlnumTicker(qRaw);
    if (s.isNotEmpty && q.startsWith(s) && q.length > s.length) {
      return q;
    }
    if (s.isNotEmpty && !q.startsWith(s)) {
      return s + q;
    }
    return q;
  }

  static bool _cexRowMatchesUserPair(
    PriceResult r,
    String ticker1,
    String ticker2,
  ) {
    if (_isCoingeckoOffchainRow(r)) {
      return _coingeckoRowMatchesCanonicalSlug(r, ticker1, ticker2);
    }
    final c1 = _cexAlnumTicker(ticker1);
    final c2 = _cexAlnumTicker(ticker2);
    if (c1.isEmpty || c2.isEmpty) {
      return false;
    }
    if (_bothNonStableAssets(ticker1, ticker2) &&
        _cexRowMatchesCrossCryptoPair(r, ticker1, ticker2)) {
      return true;
    }
    final p = _cexConcatPairId(r, ticker1);
    if (p == null || p.isEmpty) {
      return false;
    }
    final minLen = c1.length + c2.length;
    final matchesFwd =
        p.startsWith(c1) && p.endsWith(c2) && p.length >= minLen;
    final matchesRev =
        p.startsWith(c2) && p.endsWith(c1) && p.length >= minLen;
    return matchesFwd || matchesRev;
  }

  /// CoinGecko off-chain rows use API `pair` as a **coin id / slug**, not a CEX symbol.
  /// That field is stored in [PriceResult.quoteCurrency]. It must not use Binance-style
  /// `BTCUSDT` concatenation matching.
  static bool _isCoingeckoOffchainRow(PriceResult r) {
    final venue = (r.network ?? '').toLowerCase().trim();
    if (venue == 'coingecko') {
      return true;
    }
    return r.source.toLowerCase().contains('coingecko');
  }

  static bool _coingeckoRowMatchesCanonicalSlug(
    PriceResult r,
    String ticker1,
    String ticker2,
  ) {
    final rowSlug = r.quoteCurrency.trim().toLowerCase();
    for (final raw in [ticker1, ticker2]) {
      final key = raw.trim().toUpperCase();
      final canonical = MarketPairRules.coingeckoCanonicalSlugBySymbol[key];
      if (canonical != null && canonical == rowSlug) {
        return true;
      }
    }
    return false;
  }
}

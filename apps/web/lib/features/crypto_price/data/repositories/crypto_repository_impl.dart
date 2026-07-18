import 'package:cryprice_frontend/features/crypto_price/data/datasources/backend/offchain_onchain_prices_client.dart';
import 'package:cryprice_frontend/features/crypto_price/domain/constants/market_pair_rules.dart';
import 'package:cryprice_frontend/features/crypto_price/domain/entities/offchain_convert_result.dart';
import 'package:cryprice_frontend/features/crypto_price/domain/entities/price_fetch_outcome.dart';
import 'package:cryprice_frontend/features/crypto_price/domain/exceptions/crypto_exception.dart';
import 'package:cryprice_frontend/features/crypto_price/domain/repositories/crypto_repository.dart';
import 'package:cryprice_frontend/features/crypto_price/domain/entities/price_result.dart';
import 'package:cryprice_frontend/features/crypto_price/presentation/utils/display_count_parser.dart';
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
    final countValue = parseDisplayCount(count);

    final convertF = _backend.fetchOffchainConvertTraced(
      coin1: t1,
      coin2: t2,
      count: countValue,
    );

    final bothNonStablePair = _bothNonStableAssets(t1, t2);
    late final List<PriceResult> onRows;
    late final BackendPathTrace onTrace;

    if (bothNonStablePair) {
      final qh1 = _mapperQuoteHint(t1, t2, t1);
      final qh2 = _mapperQuoteHint(t1, t2, t2);
      if (kDebugMode) {
        debugPrint(
          '[cryprice] userPair=$t1/$t2 onchain dualPath qh1=$qh1 qh2=$qh2',
        );
      }
      final on1 = _backend.fetchOnchainTraced(t1, qh1, count);
      final on2 = _backend.fetchOnchainTraced(t2, qh2, count);
      final batched = await Future.wait([
        convertF,
        on1,
        on2,
      ]);
      final convertOut = batched[0] as ({
        OffchainConvertResult? result,
        BackendPathTrace trace,
      });
      onTrace = _mergeOnchainTraces(
        (batched[1] as TracedPriceRows).trace,
        (batched[2] as TracedPriceRows).trace,
      );
      onRows = [
        ...(batched[1] as TracedPriceRows).results.map((r) => _ensureSymbol(r, t1)),
        ...(batched[2] as TracedPriceRows).results.map((r) => _ensureSymbol(r, t2)),
      ];
      return _buildOutcome(
        offchainConvert: convertOut.result,
        offchainTrace: convertOut.trace,
        onchainTrace: onTrace,
        onRows: onRows,
        t1: t1,
        t2: t2,
      );
    }

    final pathAsset = _backendPathAssetForCryprice(t1, t2);
    final quoteHint = _mapperQuoteHint(t1, t2, pathAsset);
    if (kDebugMode) {
      debugPrint(
        '[cryprice] userPair=$t1/$t2 onchain pathAsset=$pathAsset quoteHint=$quoteHint',
      );
    }
    final onF = _backend.fetchOnchainTraced(pathAsset, quoteHint, count);
    final batched = await Future.wait([convertF, onF]);
    final convertOut = batched[0] as ({
      OffchainConvertResult? result,
      BackendPathTrace trace,
    });
    onTrace = (batched[1] as TracedPriceRows).trace;
    onRows = (batched[1] as TracedPriceRows).results
        .map((r) => _ensureSymbol(r, pathAsset))
        .toList();

    return _buildOutcome(
      offchainConvert: convertOut.result,
      offchainTrace: convertOut.trace,
      onchainTrace: onTrace,
      onRows: onRows,
      t1: t1,
      t2: t2,
    );
  }

  PriceFetchOutcome _buildOutcome({
    required OffchainConvertResult? offchainConvert,
    required BackendPathTrace offchainTrace,
    required BackendPathTrace onchainTrace,
    required List<PriceResult> onRows,
    required String t1,
    required String t2,
  }) {
    final dexRows = onRows
        .where((r) => r.origin == PriceResultOrigin.crypriceOnchain)
        .toList();

    final cexVenueCount = (offchainConvert?.binance != null ? 1 : 0) +
        (offchainConvert?.bybit != null ? 1 : 0);

    final debug = PriceFetchDebugSnapshot(
      onchainTrace: onchainTrace,
      offchainTrace: offchainTrace,
      mergedRowOrigins: dexRows.map((r) => r.origin.name).toList(),
      repositoryTotalRows: dexRows.length + cexVenueCount,
      cexCountAfterGroup: cexVenueCount,
      dexCountAfterGroup: dexRows.length,
    );

    _throwIfNoData(
      offchainConvert: offchainConvert,
      dexRows: dexRows,
      traces: [offchainTrace, onchainTrace],
    );

    return PriceFetchOutcome(
      results: dexRows,
      debug: debug,
      offchainConvert: offchainConvert,
    );
  }

  PriceResult _ensureSymbol(PriceResult r, String pathAsset) {
    if (r.symbol == null || r.symbol!.isEmpty) {
      return r.copyWith(symbol: pathAsset);
    }
    return r;
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

  static void _throwIfNoData({
    required OffchainConvertResult? offchainConvert,
    required List<PriceResult> dexRows,
    required List<BackendPathTrace> traces,
  }) {
    final hasCex = offchainConvert?.hasAnyVenue ?? false;
    if (hasCex || dexRows.isNotEmpty) {
      return;
    }
    if (traces.any((trace) => trace.statusCode == 429)) {
      throw CryptoException(CryptoErrorCode.rateLimited);
    }
    throw CryptoException(CryptoErrorCode.fetchFailed);
  }
}

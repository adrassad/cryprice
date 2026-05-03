import 'package:crypto_tracker_app/features/crypto_price/domain/entities/price_result.dart';

/// One HTTP call to `/prices/current/offchain/` or `/onchain/`.
class BackendPathTrace {
  BackendPathTrace({
    required this.path,
    required this.isOnchainEndpoint,
    this.resolvedBaseUrl = '',
    this.fullRequestUrl = '',
    this.httpAttempted = false,
    this.statusCode,
    this.rawDataRuntimeType = 'unknown',
    this.rawDataPreview = '',
    this.parsedDtoCount = 0,
    this.mappedResultCount = 0,
    this.networkKeys = const [],
    this.rowOriginNames = const [],
    this.error,
  });

  final String path;
  /// [Dio.options.baseUrl] at request time (runtime proof).
  final String resolvedBaseUrl;
  /// Absolute URL: base + path (e.g. `{baseUrl}/prices/current/offchain/wbtc`).
  final String fullRequestUrl;
  final bool isOnchainEndpoint;
  final bool httpAttempted;
  final int? statusCode;
  final String rawDataRuntimeType;
  final String rawDataPreview;
  final int parsedDtoCount;
  final int mappedResultCount;
  final List<String> networkKeys;
  final List<String> rowOriginNames;
  final String? error;
}

class PriceFetchDebugSnapshot {
  const PriceFetchDebugSnapshot({
    required this.onchainTrace,
    required this.offchainTrace,
    required this.mergedRowOrigins,
    required this.repositoryTotalRows,
    required this.cexCountAfterGroup,
    required this.dexCountAfterGroup,
  });

  final BackendPathTrace onchainTrace;
  final BackendPathTrace offchainTrace;
  final List<String> mergedRowOrigins;
  /// [PriceResult] count after repository merge (off-chain + on-chain rows).
  final int repositoryTotalRows;
  final int cexCountAfterGroup;
  final int dexCountAfterGroup;

  bool get onchainEndpointCalled => onchainTrace.httpAttempted;
  int get parsedOnchainRows => onchainTrace.parsedDtoCount;
  String get onchainRawType => onchainTrace.rawDataRuntimeType;
}

class TracedPriceRows {
  const TracedPriceRows(this.results, this.trace);
  final List<PriceResult> results;
  final BackendPathTrace trace;
}

class PriceFetchOutcome {
  const PriceFetchOutcome({
    required this.results,
    required this.debug,
  });

  final List<PriceResult> results;
  final PriceFetchDebugSnapshot debug;
}

// HTTP for `GET /prices/current/offchain/{symbol}` and `GET /prices/current/onchain/{symbol}`.
// One request returns all networks for that symbol (bulk map). Origin is set only from the URL path.
import 'package:crypto_tracker_app/core/config/cryprice_backend_config.dart';
import 'package:crypto_tracker_app/features/crypto_price/data/datasources/base_api_provider.dart';
import 'package:crypto_tracker_app/features/crypto_price/data/models/current_price_dto.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/entities/price_fetch_outcome.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/entities/price_result.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/exceptions/crypto_exception.dart';
import 'package:dio/dio.dart';

/// Parser for one backend path only — off-chain and on-chain contracts differ.
typedef _OffOnBodyParser = List<CurrentPriceItemDto> Function(
  Object? data, {
  DateTime? now,
});

/// Single Cryprice backend client for aggregated prices (off-chain + on-chain paths).
/// Prefer this name in new code: [CrypriceBackendPricesClient].
class OffchainOnchainPricesClient extends BaseApiProvider {
  OffchainOnchainPricesClient({
    String? baseUrl,
    Dio? dio,
  }) : super(
         baseUrl: baseUrl ?? crypriceBackendBaseUrl,
         dio: dio ?? _defaultDio(baseUrl ?? crypriceBackendBaseUrl),
       );

  static Dio _defaultDio(String baseUrl) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        responseType: ResponseType.json,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: <String, dynamic>{
          'Accept': 'application/json',
        },
      ),
    );
  }

  static const _offchainPrefix = '/prices/current/offchain/';
  static const _onchainPrefix = '/prices/current/onchain/';

  /// Normalized path segment (e.g. `btc`) for `/prices/.../onchain/{symbol}`.
  static String symbolPathSegment(String raw) {
    final s = raw.trim().toLowerCase();
    if (s.isEmpty) {
      return '';
    }
    return Uri.encodeComponent(s);
  }

  /// `GET /prices/current/offchain/{symbol}` -> [PriceResultOrigin.crypriceOffchain] (CEX section).
  Future<List<PriceResult>> fetchOffchain(
    String from,
    String to,
    String count,
  ) {
    return fetchOffchainTraced(from, to, count).then((r) => r.results);
  }

  /// `GET /prices/current/onchain/{symbol}` -> [PriceResultOrigin.crypriceOnchain] (DEX section only).
  Future<List<PriceResult>> fetchOnchain(
    String from,
    String to,
    String count,
  ) {
    return fetchOnchainTraced(from, to, count).then((r) => r.results);
  }

  Future<TracedPriceRows> fetchOffchainTraced(
    String from,
    String to,
    String count,
  ) {
    return _tracedHttpGet(
      path: '$_offchainPrefix${symbolPathSegment(from)}',
      isOnchainEndpoint: false,
      from: from,
      to: to,
      parseBody: parseOffchainBackendResponse,
    );
  }

  Future<TracedPriceRows> fetchOnchainTraced(
    String from,
    String to,
    String count,
  ) {
    return _tracedHttpGet(
      path: '$_onchainPrefix${symbolPathSegment(from)}',
      isOnchainEndpoint: true,
      from: from,
      to: to,
      parseBody: parseOnchainPerNetworkMap,
    );
  }

  static String _resolvedBaseUrl(Dio dio) {
    return _stripSlash(dio.options.baseUrl);
  }

  static String _fullRequestUrl(Dio dio, String path) {
    final base = _resolvedBaseUrl(dio);
    final p = path.startsWith('/') ? path : '/$path';
    return '$base$p';
  }

  static String _stripSlash(String s) {
    var t = s.trim();
    while (t.endsWith('/')) {
      t = t.substring(0, t.length - 1);
    }
    return t;
  }

  Future<TracedPriceRows> _tracedHttpGet({
    required String path,
    required bool isOnchainEndpoint,
    required String from,
    required String to,
    required _OffOnBodyParser parseBody,
  }) async {
    final origin = isOnchainEndpoint
        ? PriceResultOrigin.crypriceOnchain
        : PriceResultOrigin.crypriceOffchain;
    final priceType =
        isOnchainEndpoint ? PriceType.onchain : PriceType.offchain;
    final baseUrl = _resolvedBaseUrl(dio);
    final fullUrl = _fullRequestUrl(dio, path);

    try {
      final response = await safeGet(path);
      final status = response.statusCode ?? 0;
      final body = response.data;
      final rawType = _runtimeTypeName(body);
      final preview = _rawPreview(body);

      if (status != 200) {
        return TracedPriceRows(
          <PriceResult>[],
          BackendPathTrace(
            path: path,
            isOnchainEndpoint: isOnchainEndpoint,
            resolvedBaseUrl: baseUrl,
            fullRequestUrl: fullUrl,
            httpAttempted: true,
            statusCode: status,
            rawDataRuntimeType: rawType,
            rawDataPreview: preview,
            error: 'non-200 status',
          ),
        );
      }

      final now = DateTime.now();
      final List<CurrentPriceItemDto> dtos = parseBody(body, now: now);

      final results = dtos
          .map(
            (d) => d.toPriceResult(
                  from,
                  to,
                  priceType: priceType,
                  origin: origin,
                ),
          )
          .toList();

      final networkKeys = dtos
          .map((d) => d.network)
          .whereType<String>()
          .toList();
      final origins = results.map((r) => r.origin.name).toList();

      return TracedPriceRows(
        results,
        BackendPathTrace(
          path: path,
          isOnchainEndpoint: isOnchainEndpoint,
          resolvedBaseUrl: baseUrl,
          fullRequestUrl: fullUrl,
          httpAttempted: true,
          statusCode: status,
          rawDataRuntimeType: rawType,
          rawDataPreview: preview,
          parsedDtoCount: dtos.length,
          mappedResultCount: results.length,
          networkKeys: networkKeys,
          rowOriginNames: origins,
        ),
      );
    } on CryptoException {
      // Keep network/domain errors semantic for upper layers (Cubit/UI).
      rethrow;
    } catch (e, st) {
      return TracedPriceRows(
        <PriceResult>[],
        BackendPathTrace(
          path: path,
          isOnchainEndpoint: isOnchainEndpoint,
          resolvedBaseUrl: baseUrl,
          fullRequestUrl: fullUrl,
          httpAttempted: true,
          error: '$e | $st',
        ),
      );
    }
  }

  static String _runtimeTypeName(Object? o) {
    if (o == null) {
      return 'null';
    }
    if (o is String) {
      return 'String';
    }
    if (o is Map) {
      return 'Map';
    }
    if (o is List) {
      return 'List';
    }
    return o.runtimeType.toString();
  }

  static String _rawPreview(Object? data, [int max = 300]) {
    if (data == null) {
      return '(null)';
    }
    if (data is String) {
      if (data.length <= max) {
        return data;
      }
      return '${data.substring(0, max)}…';
    }
    if (data is Map) {
      final k = data.keys.take(12).map((e) => e.toString()).join(', ');
      return 'Map keys(≤12): $k  (size=${data.length})';
    }
    if (data is List) {
      return 'List len=${data.length}';
    }
    return data.toString();
  }
}

/// App-wide alias: production price fetches use this backend only (no direct exchange HTTP).
typedef CrypriceBackendPricesClient = OffchainOnchainPricesClient;

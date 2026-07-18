// HTTP for `GET /prices/current/offchain/{symbol}` and `GET /prices/current/onchain/{symbol}`.
// One request returns all networks for that symbol (bulk map). Origin is set only from the URL path.
import 'package:cryprice_frontend/core/config/cryprice_backend_config.dart';
import 'package:cryprice_frontend/features/crypto_price/data/datasources/base_api_provider.dart';
import 'package:cryprice_frontend/features/crypto_price/data/models/current_price_dto.dart';
import 'package:cryprice_frontend/features/crypto_price/data/models/offchain_convert_dto.dart';
import 'package:cryprice_frontend/features/crypto_price/domain/entities/offchain_convert_result.dart';
import 'package:cryprice_frontend/features/crypto_price/domain/entities/price_fetch_outcome.dart';
import 'package:cryprice_frontend/features/crypto_price/domain/entities/price_result.dart';
import 'package:cryprice_frontend/features/crypto_price/domain/exceptions/crypto_exception.dart';
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
  static const _offchainConvertPath = '/prices/convert/offchain';
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

  /// `POST /prices/convert/offchain` — backend-computed CEX conversion per venue.
  Future<({OffchainConvertResult? result, BackendPathTrace trace})>
  fetchOffchainConvertTraced({
    required String coin1,
    required String coin2,
    required double count,
  }) async {
    final path = _offchainConvertPath;
    final baseUrl = _resolvedBaseUrl(dio);
    final fullUrl = _fullRequestUrl(dio, path);
    final body = <String, dynamic>{
      'coin1': coin1.trim().toUpperCase(),
      'coin2': coin2.trim().toUpperCase(),
      'count': count,
    };

    try {
      final response = await dio.post<dynamic>(
        path,
        data: body,
        options: Options(
          validateStatus: (int? status) => status != null && status < 500,
        ),
      );
      final status = response.statusCode ?? 0;
      final raw = response.data;
      final rawType = _runtimeTypeName(raw);
      final preview = _rawPreview(raw);

      if (status == 404) {
        return (
          result: null,
          trace: BackendPathTrace(
            path: path,
            isOnchainEndpoint: false,
            resolvedBaseUrl: baseUrl,
            fullRequestUrl: fullUrl,
            httpAttempted: true,
            statusCode: status,
            rawDataRuntimeType: rawType,
            rawDataPreview: preview,
            error: 'conversion_not_available',
          ),
        );
      }

      if (status == 429) {
        throw CryptoException(CryptoErrorCode.rateLimited);
      }

      if (status != 200) {
        throw CryptoException(CryptoErrorCode.fetchFailed);
      }

      final dto = OffchainConvertDto.fromDynamic(raw);
      if (dto == null) {
        throw CryptoException(CryptoErrorCode.fetchFailed);
      }
      final entity = dto.toEntity();

      return (
        result: entity,
        trace: BackendPathTrace(
          path: path,
          isOnchainEndpoint: false,
          resolvedBaseUrl: baseUrl,
          fullRequestUrl: fullUrl,
          httpAttempted: true,
          statusCode: status,
          rawDataRuntimeType: rawType,
          rawDataPreview: preview,
          parsedDtoCount: 1,
          mappedResultCount: entity.hasAnyVenue ? 1 : 0,
        ),
      );
    } on CryptoException {
      rethrow;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw CryptoException(CryptoErrorCode.noInternet);
      }
      if (e.response?.statusCode == 429) {
        throw CryptoException(CryptoErrorCode.rateLimited);
      }
      throw CryptoException(CryptoErrorCode.fetchFailed);
    } catch (_) {
      throw CryptoException(CryptoErrorCode.unknown);
    }
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

  /// Cryprice price paths use 404 when a ticker has no rows; treat as empty, not fatal.
  Future<Response<dynamic>> _getPricesPath(String path) async {
    try {
      return await dio.get<dynamic>(
        path,
        options: Options(
          validateStatus: (int? status) => status != null && status < 500,
        ),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw CryptoException(CryptoErrorCode.noInternet);
      }
      throw CryptoException(CryptoErrorCode.fetchFailed);
    } catch (_) {
      throw CryptoException(CryptoErrorCode.unknown);
    }
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
      // 404 = no quotes for this ticker on this path; other leg may still succeed.
      final response = await _getPricesPath(path);
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
            error: status == 404 ? 'not found (empty)' : 'non-200 status',
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

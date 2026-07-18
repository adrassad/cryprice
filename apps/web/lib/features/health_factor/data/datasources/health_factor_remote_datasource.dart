import 'package:cryprice_frontend/core/config/cryprice_backend_config.dart';
import 'package:cryprice_frontend/core/network/api_error_parser.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_calculate_request_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_calculate_response_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_markets_response_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_network_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_protocol_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_protocol_path.dart';
import 'package:dio/dio.dart';

/// HTTP client for `/health-factor/*` on [crypriceBackendBaseUrl].
class HealthFactorRemoteDataSource {
  HealthFactorRemoteDataSource({
    Dio? dio,
    String? baseUrl,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? crypriceBackendBaseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                headers: const <String, Object?>{
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            );

  final Dio _dio;

  static const String _protocolsPath = '/health-factor/protocols';
  static const String _networksPath = '/health-factor/networks';

  Future<List<HealthFactorProtocolModel>> getProtocols() async {
    try {
      final response = await _dio.get<dynamic>(_protocolsPath);
      return HealthFactorProtocolModel.listFromResponse(response.data);
    } on Object catch (e) {
      throw parseApiError(e);
    }
  }

  Future<List<HealthFactorNetworkModel>> getNetworks({
    required String protocol,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        _networksPath,
        queryParameters: <String, Object?>{
          'protocol': _protocolQueryParam(protocol),
        },
      );
      return HealthFactorNetworkModel.listFromResponse(response.data);
    } on Object catch (e) {
      throw parseApiError(e);
    }
  }

  Future<HealthFactorMarketsResponseModel> getMarkets({
    required String protocol,
    required String network,
    String? marketId,
    bool? onlyActive,
    bool? onlySupplyEnabled,
    bool? onlyBorrowEnabled,
    bool? onlyCollateralEnabled,
    String? search,
  }) async {
    try {
      final slug = HealthFactorProtocolPath.slugFromQuery(protocol);
      final query = <String, Object?>{
        'network': network.trim(),
        if (marketId != null && marketId.trim().isNotEmpty) 'marketId': marketId.trim(),
        if (onlyActive != null) 'onlyActive': onlyActive,
        if (onlySupplyEnabled != null) 'onlySupplyEnabled': onlySupplyEnabled,
        if (onlyBorrowEnabled != null) 'onlyBorrowEnabled': onlyBorrowEnabled,
        if (onlyCollateralEnabled != null) 'onlyCollateralEnabled': onlyCollateralEnabled,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      };
      final response = await _dio.get<dynamic>(
        '/health-factor/$slug/markets',
        queryParameters: query,
      );
      return HealthFactorMarketsResponseModel.fromResponseData(response.data);
    } on Object catch (e) {
      throw parseApiError(e);
    }
  }

  /// Public stateless calculate (`POST /health-factor/{slug}/calculate`).
  Future<HealthFactorCalculateResponseModel> calculate({
    required HealthFactorCalculateRequestModel request,
    required String protocol,
  }) async {
    try {
      final slug = HealthFactorProtocolPath.slugFromQuery(protocol);
      final body = request.toJson();
      final response = await _dio.post<dynamic>(
        '/health-factor/$slug/calculate',
        data: body,
      );
      return HealthFactorCalculateResponseModel.fromResponseData(response.data);
    } on Object catch (e) {
      throw parseApiError(e);
    }
  }

  static String _protocolQueryParam(String protocol) {
    final trimmed = protocol.trim();
    if (trimmed.contains('_')) {
      return trimmed;
    }
    return HealthFactorProtocolPath.queryFromSlug(trimmed);
  }
}

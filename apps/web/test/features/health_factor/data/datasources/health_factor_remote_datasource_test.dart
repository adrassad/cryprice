import 'package:cryprice_frontend/core/network/api_error.dart';
import 'package:cryprice_frontend/features/health_factor/data/datasources/health_factor_remote_datasource.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_calculate_request_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('getProtocols', () {
    test('calls GET /health-factor/protocols without Authorization', () async {
      RequestOptions? captured;
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            captured = options;
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: _protocolsResponse(),
              ),
            );
          },
        ),
      );
      final dataSource = HealthFactorRemoteDataSource(dio: dio);

      final protocols = await dataSource.getProtocols();

      expect(captured?.path, '/health-factor/protocols');
      expect(captured?.headers['Authorization'], isNull);
      expect(protocols.single.id, 'aave_v3');
    });
  });

  group('getNetworks', () {
    test('calls GET /health-factor/networks?protocol=aave_v3 without Authorization', () async {
      RequestOptions? captured;
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            captured = options;
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: _networksResponse(),
              ),
            );
          },
        ),
      );
      final dataSource = HealthFactorRemoteDataSource(dio: dio);

      final networks = await dataSource.getNetworks(protocol: 'aave_v3');

      expect(captured?.path, '/health-factor/networks');
      expect(captured?.queryParameters['protocol'], 'aave_v3');
      expect(captured?.headers['Authorization'], isNull);
      expect(networks.single.name, 'arbitrum');
    });
  });

  group('getMarkets', () {
    test('calls GET /health-factor/aave-v3/markets with query params without Authorization', () async {
      RequestOptions? captured;
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            captured = options;
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: _marketsResponse(),
              ),
            );
          },
        ),
      );
      final dataSource = HealthFactorRemoteDataSource(dio: dio);

      await dataSource.getMarkets(
        protocol: 'aave_v3',
        network: 'arbitrum',
        onlyActive: true,
        search: 'eth',
      );

      expect(captured?.path, '/health-factor/aave-v3/markets');
      expect(captured?.queryParameters['network'], 'arbitrum');
      expect(captured?.queryParameters['onlyActive'], true);
      expect(captured?.queryParameters['search'], 'eth');
      expect(captured?.headers['Authorization'], isNull);
    });
  });

  group('calculate', () {
    test('calls POST /health-factor/aave-v3/calculate without Authorization', () async {
      RequestOptions? captured;
      Map<String, Object?>? capturedBody;
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            captured = options;
            capturedBody = options.data as Map<String, Object?>?;
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: _calculateResponse(),
              ),
            );
          },
        ),
      );
      final dataSource = HealthFactorRemoteDataSource(dio: dio);

      final result = await dataSource.calculate(
        protocol: 'aave_v3',
        request: const HealthFactorCalculateRequestModel(
          network: 'arbitrum',
          supplies: [
            HealthFactorSupplyInputModel(assetId: '10', amount: '1'),
          ],
          borrows: [],
        ),
      );

      expect(captured?.method, 'POST');
      expect(captured?.path, '/health-factor/aave-v3/calculate');
      expect(captured?.headers['Authorization'], isNull);
      expect(capturedBody?['network'], 'arbitrum');
      expect(capturedBody?.containsKey('userId'), isFalse);
      expect(capturedBody?.containsKey('user_id'), isFalse);
      expect(result.healthFactorDisplay, '1.73');
    });

    test('maps DioException via parseApiError', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response<dynamic>(
                  requestOptions: options,
                  statusCode: 400,
                  data: const <String, Object?>{
                    'error': <String, Object?>{
                      'code': 'INVALID_POSITION',
                      'message': 'Invalid supply row',
                    },
                  },
                ),
              ),
            );
          },
        ),
      );
      final dataSource = HealthFactorRemoteDataSource(dio: dio);

      final call = dataSource.calculate(
        request: const HealthFactorCalculateRequestModel(network: 'arbitrum'),
      );

      await expectLater(
        call,
        throwsA(
          isA<ApiError>()
              .having((e) => e.code, 'code', 'INVALID_POSITION')
              .having((e) => e.message, 'message', 'Invalid supply row')
              .having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
    });
  });
}

Map<String, Object?> _protocolsResponse() {
  return <String, Object?>{
    'protocols': [
      <String, Object?>{
        'id': 'aave_v3',
        'name': 'Aave V3',
        'version': '3',
        'hasReserveData': true,
      },
    ],
  };
}

Map<String, Object?> _networksResponse() {
  return <String, Object?>{
    'protocol': 'aave_v3',
    'networks': [
      <String, Object?>{
        'id': 2,
        'name': 'arbitrum',
        'chainId': 42161,
        'nativeSymbol': 'ETH',
      },
    ],
  };
}

Map<String, Object?> _marketsResponse() {
  return <String, Object?>{
    'market': <String, Object?>{
      'protocol': 'aave_v3',
      'network': <String, Object?>{
        'id': 2,
        'name': 'arbitrum',
        'chainId': 42161,
      },
      'marketId': null,
      'reserves': <Object?>[],
    },
  };
}

Map<String, Object?> _calculateResponse() {
  return <String, Object?>{
    'calculation': <String, Object?>{
      'protocol': 'aave_v3',
      'network': <String, Object?>{
        'id': 2,
        'name': 'arbitrum',
        'chainId': 42161,
      },
      'healthFactor': '1.7325',
      'healthFactorDisplay': '1.73',
      'isInfinite': false,
      'riskLevel': 'high',
      'totals': <String, Object?>{
        'collateralUsd': '5250',
        'collateralWeightedUsd': '4331.25',
        'borrowUsd': '2500',
      },
      'positions': <String, Object?>{
        'supplies': <Object?>[],
        'borrows': <Object?>[],
      },
      'warnings': <Object?>[],
    },
  };
}

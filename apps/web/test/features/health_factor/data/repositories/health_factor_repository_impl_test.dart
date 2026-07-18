import 'package:cryprice_frontend/core/network/api_error.dart';
import 'package:cryprice_frontend/features/health_factor/data/datasources/health_factor_remote_datasource.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_calculate_request_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_calculate_response_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_markets_response_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_network_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_position_breakdown_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_protocol_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_totals_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/repositories/health_factor_repository_impl.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_calculate_request.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHealthFactorRemoteDataSource extends Mock
    implements HealthFactorRemoteDataSource {}

void main() {
  late MockHealthFactorRemoteDataSource remote;
  late HealthFactorRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      const HealthFactorCalculateRequestModel(network: 'fallback'),
    );
  });

  setUp(() {
    remote = MockHealthFactorRemoteDataSource();
    repository = HealthFactorRepositoryImpl(remote: remote);
  });

  test('getProtocols delegates to remote and maps entities', () async {
    const models = [
      HealthFactorProtocolModel(
        id: 'aave_v3',
        name: 'Aave V3',
        version: '3',
        hasReserveData: true,
      ),
    ];
    when(() => remote.getProtocols()).thenAnswer((_) async => models);

    final result = await repository.getProtocols();

    expect(result, hasLength(1));
    expect(result.single.id, 'aave_v3');
    expect(result.single.hasReserveData, isTrue);
    verify(() => remote.getProtocols()).called(1);
  });

  test('getNetworks delegates to remote and maps entities', () async {
    const models = [
      HealthFactorNetworkModel(
        id: 2,
        name: 'arbitrum',
        chainId: 42161,
        nativeSymbol: 'ETH',
      ),
    ];
    when(() => remote.getNetworks(protocol: 'aave_v3')).thenAnswer((_) async => models);

    final result = await repository.getNetworks(protocol: 'aave_v3');

    expect(result.single.id, '2');
    expect(result.single.name, 'arbitrum');
    verify(() => remote.getNetworks(protocol: 'aave_v3')).called(1);
  });

  test('getMarkets delegates to remote and maps entity', () async {
    const model = HealthFactorMarketsResponseModel(
      protocol: 'aave_v3',
      network: HealthFactorNetworkModel(id: 2, name: 'arbitrum', chainId: 42161),
    );
    when(
      () => remote.getMarkets(
        protocol: 'aave_v3',
        network: 'arbitrum',
        marketId: null,
        onlyActive: true,
        onlySupplyEnabled: null,
        onlyBorrowEnabled: null,
        onlyCollateralEnabled: null,
        search: null,
      ),
    ).thenAnswer((_) async => model);

    final result = await repository.getMarkets(
      protocol: 'aave_v3',
      network: 'arbitrum',
      onlyActive: true,
    );

    expect(result.protocol, 'aave_v3');
    expect(result.network.name, 'arbitrum');
    verify(
      () => remote.getMarkets(
        protocol: 'aave_v3',
        network: 'arbitrum',
        marketId: null,
        onlyActive: true,
        onlySupplyEnabled: null,
        onlyBorrowEnabled: null,
        onlyCollateralEnabled: null,
        search: null,
      ),
    ).called(1);
  });

  test('calculate delegates to remote and maps entity', () async {
    const response = HealthFactorCalculateResponseModel(
      protocol: 'aave_v3',
      network: HealthFactorNetworkModel(id: 2, name: 'arbitrum', chainId: 42161),
      healthFactor: '1.73',
      healthFactorDisplay: '1.73',
      riskLevel: 'high',
      totals: HealthFactorTotalsModel(
        collateralUsd: '100',
        collateralWeightedUsd: '80',
        borrowUsd: '50',
      ),
      positions: HealthFactorPositionsBreakdownModel(),
    );
    const request = HealthFactorCalculateRequest(
      protocol: 'aave_v3',
      network: 'arbitrum',
      supplies: [HealthFactorSupplyInput(assetId: '10', amount: '1')],
    );
    when(
      () => remote.calculate(
        request: any(named: 'request'),
        protocol: any(named: 'protocol'),
      ),
    ).thenAnswer((_) async => response);

    final result = await repository.calculate(request: request);

    expect(result.healthFactorDisplay, '1.73');
    expect(result.totals.borrowUsd, '50');
    verify(
      () => remote.calculate(
        request: any(named: 'request'),
        protocol: any(named: 'protocol'),
      ),
    ).called(1);
  });

  test('getProtocols propagates remote errors', () async {
    const error = ApiError(
      message: 'Unavailable',
      code: 'HF_UNAVAILABLE',
      statusCode: 503,
    );
    when(() => remote.getProtocols()).thenAnswer((_) async {
      throw error;
    });

    expect(
      repository.getProtocols(),
      throwsA(
        isA<ApiError>()
            .having((e) => e.code, 'code', 'HF_UNAVAILABLE')
            .having((e) => e.statusCode, 'statusCode', 503),
      ),
    );
  });
}

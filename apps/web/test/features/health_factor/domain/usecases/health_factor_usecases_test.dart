import 'package:cryprice_frontend/core/network/api_error.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_calculate_request.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_calculate_result.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_markets_result.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_network.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_position_breakdown.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_protocol.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_totals.dart';
import 'package:cryprice_frontend/features/health_factor/domain/repositories/health_factor_repository.dart';
import 'package:cryprice_frontend/features/health_factor/domain/usecases/calculate_health_factor_usecase.dart';
import 'package:cryprice_frontend/features/health_factor/domain/usecases/get_health_factor_markets_usecase.dart';
import 'package:cryprice_frontend/features/health_factor/domain/usecases/get_health_factor_networks_usecase.dart';
import 'package:cryprice_frontend/features/health_factor/domain/usecases/get_health_factor_protocols_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHealthFactorRepository extends Mock implements HealthFactorRepository {}

void main() {
  late MockHealthFactorRepository repository;

  setUp(() {
    repository = MockHealthFactorRepository();
  });

  test('GetHealthFactorProtocolsUseCase delegates to repository', () async {
    const protocols = [
      HealthFactorProtocol(id: 'aave_v3', name: 'Aave V3'),
    ];
    when(() => repository.getProtocols()).thenAnswer((_) async => protocols);

    final useCase = GetHealthFactorProtocolsUseCase(repository);
    final result = await useCase.execute();

    expect(result, same(protocols));
    verify(() => repository.getProtocols()).called(1);
  });

  test('GetHealthFactorNetworksUseCase delegates to repository', () async {
    const networks = [
      HealthFactorNetwork(id: '2', name: 'arbitrum', chainId: 42161),
    ];
    when(() => repository.getNetworks(protocol: 'aave_v3')).thenAnswer((_) async => networks);

    final useCase = GetHealthFactorNetworksUseCase(repository);
    final result = await useCase.execute(protocol: 'aave_v3');

    expect(result, same(networks));
    verify(() => repository.getNetworks(protocol: 'aave_v3')).called(1);
  });

  test('GetHealthFactorMarketsUseCase delegates to repository', () async {
    const markets = HealthFactorMarketsResult(
      protocol: 'aave_v3',
      network: HealthFactorNetwork(id: '2', name: 'arbitrum', chainId: 42161),
    );
    when(
      () => repository.getMarkets(
        protocol: 'aave_v3',
        network: 'arbitrum',
        marketId: null,
        onlyActive: null,
        onlySupplyEnabled: null,
        onlyBorrowEnabled: null,
        onlyCollateralEnabled: null,
        search: null,
      ),
    ).thenAnswer((_) async => markets);

    final useCase = GetHealthFactorMarketsUseCase(repository);
    final result = await useCase.execute(protocol: 'aave_v3', network: 'arbitrum');

    expect(result, same(markets));
    verify(
      () => repository.getMarkets(
        protocol: 'aave_v3',
        network: 'arbitrum',
        marketId: null,
        onlyActive: null,
        onlySupplyEnabled: null,
        onlyBorrowEnabled: null,
        onlyCollateralEnabled: null,
        search: null,
      ),
    ).called(1);
  });

  test('CalculateHealthFactorUseCase delegates to repository', () async {
    const request = HealthFactorCalculateRequest(protocol: 'aave_v3', network: 'arbitrum');
    const resultEntity = HealthFactorCalculateResult(
      protocol: 'aave_v3',
      network: HealthFactorNetwork(id: '2', name: 'arbitrum', chainId: 42161),
      healthFactorDisplay: '1.5',
      riskLevel: 'watch',
      totals: HealthFactorTotals(
        collateralUsd: '100',
        collateralWeightedUsd: '80',
        borrowUsd: '50',
      ),
      positions: HealthFactorPositionsBreakdown(),
    );
    when(() => repository.calculate(request: request)).thenAnswer((_) async => resultEntity);

    final useCase = CalculateHealthFactorUseCase(repository);
    final result = await useCase.execute(request: request);

    expect(result, same(resultEntity));
    verify(() => repository.calculate(request: request)).called(1);
  });

  test('use case propagates repository errors', () async {
    const error = ApiError(message: 'Failed', code: 'HF_FAILED', statusCode: 500);
    when(() => repository.getProtocols()).thenAnswer((_) async {
      throw error;
    });

    final useCase = GetHealthFactorProtocolsUseCase(repository);

    expect(
      useCase.execute(),
      throwsA(isA<ApiError>().having((e) => e.code, 'code', 'HF_FAILED')),
    );
  });
}

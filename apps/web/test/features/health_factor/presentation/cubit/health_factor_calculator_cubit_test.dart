import 'package:bloc_test/bloc_test.dart';
import 'package:cryprice_frontend/core/network/api_error.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_asset.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_calculate_request.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_calculate_result.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_flags.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_market_reserve.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_markets_result.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_network.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_position_breakdown.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_price.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_protocol.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_risk.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_totals.dart';
import 'package:cryprice_frontend/features/health_factor/domain/usecases/calculate_health_factor_usecase.dart';
import 'package:cryprice_frontend/features/health_factor/domain/usecases/get_health_factor_markets_usecase.dart';
import 'package:cryprice_frontend/features/health_factor/domain/usecases/get_health_factor_networks_usecase.dart';
import 'package:cryprice_frontend/features/health_factor/domain/usecases/get_health_factor_protocols_usecase.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/cubit/health_factor_calculator_cubit.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/cubit/health_factor_calculator_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetHealthFactorProtocolsUseCase extends Mock
    implements GetHealthFactorProtocolsUseCase {}

class MockGetHealthFactorNetworksUseCase extends Mock
    implements GetHealthFactorNetworksUseCase {}

class MockGetHealthFactorMarketsUseCase extends Mock
    implements GetHealthFactorMarketsUseCase {}

class MockCalculateHealthFactorUseCase extends Mock
    implements CalculateHealthFactorUseCase {}

HealthFactorCalculatorCubit _buildCubit({
  required MockGetHealthFactorProtocolsUseCase getProtocols,
  required MockGetHealthFactorNetworksUseCase getNetworks,
  required MockGetHealthFactorMarketsUseCase getMarkets,
  required MockCalculateHealthFactorUseCase calculate,
}) {
  return HealthFactorCalculatorCubit(
    getProtocolsUseCase: getProtocols,
    getNetworksUseCase: getNetworks,
    getMarketsUseCase: getMarkets,
    calculateHealthFactorUseCase: calculate,
  );
}

void main() {
  late MockGetHealthFactorProtocolsUseCase getProtocols;
  late MockGetHealthFactorNetworksUseCase getNetworks;
  late MockGetHealthFactorMarketsUseCase getMarkets;
  late MockCalculateHealthFactorUseCase calculate;

  setUpAll(() {
    registerFallbackValue(
      const HealthFactorCalculateRequest(protocol: 'aave_v3', network: 'fallback'),
    );
  });

  setUp(() {
    getProtocols = MockGetHealthFactorProtocolsUseCase();
    getNetworks = MockGetHealthFactorNetworksUseCase();
    getMarkets = MockGetHealthFactorMarketsUseCase();
    calculate = MockCalculateHealthFactorUseCase();
  });

  test('initial state is initial', () {
    final cubit = _buildCubit(
      getProtocols: getProtocols,
      getNetworks: getNetworks,
      getMarkets: getMarkets,
      calculate: calculate,
    );
    expect(cubit.state.status, HealthFactorCalculatorStatus.initial);
    cubit.close();
  });

  blocTest<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
    'initialize loads catalogs and emits ready with default rows',
    build: () {
      _stubCatalogSuccess(
        getProtocols: getProtocols,
        getNetworks: getNetworks,
        getMarkets: getMarkets,
      );
      return _buildCubit(
        getProtocols: getProtocols,
        getNetworks: getNetworks,
        getMarkets: getMarkets,
        calculate: calculate,
      );
    },
    act: (cubit) => cubit.initialize(),
    expect: () => [
      isA<HealthFactorCalculatorState>().having(
        (s) => s.status,
        'status',
        HealthFactorCalculatorStatus.loadingProtocols,
      ),
      isA<HealthFactorCalculatorState>().having(
        (s) => s.status,
        'status',
        HealthFactorCalculatorStatus.loadingNetworks,
      ),
      isA<HealthFactorCalculatorState>().having(
        (s) => s.status,
        'status',
        HealthFactorCalculatorStatus.loadingMarkets,
      ),
      isA<HealthFactorCalculatorState>()
          .having((s) => s.status, 'status', HealthFactorCalculatorStatus.ready)
          .having((s) => s.selectedProtocol?.id, 'protocol', kHealthFactorAaveV3ProtocolId)
          .having((s) => s.selectedNetwork?.name, 'network', 'arbitrum')
          .having((s) => s.market, 'market', isNotNull)
          .having((s) => s.supplies, 'supplies', hasLength(1))
          .having((s) => s.borrows, 'borrows', hasLength(1)),
    ],
  );

  blocTest<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
    'initialize is idempotent when metadata is already loaded',
    build: () {
      _stubCatalogSuccess(
        getProtocols: getProtocols,
        getNetworks: getNetworks,
        getMarkets: getMarkets,
      );
      return _buildCubit(
        getProtocols: getProtocols,
        getNetworks: getNetworks,
        getMarkets: getMarkets,
        calculate: calculate,
      );
    },
    act: (cubit) async {
      await cubit.initialize();
      await cubit.initialize();
    },
    verify: (_) {
      verify(() => getProtocols.execute()).called(1);
    },
  );

  blocTest<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
    'initialize selects aave_v3 when multiple protocols returned',
    build: () {
      when(() => getProtocols.execute()).thenAnswer(
        (_) async => const [
          HealthFactorProtocol(id: 'other', name: 'Other'),
          HealthFactorProtocol(id: kHealthFactorAaveV3ProtocolId, name: 'Aave V3'),
        ],
      );
      when(() => getNetworks.execute(protocol: kHealthFactorAaveV3ProtocolId)).thenAnswer(
        (_) async => [_arbitrumNetwork()],
      );
      when(
        () => getMarkets.execute(
          protocol: kHealthFactorAaveV3ProtocolId,
          network: 'arbitrum',
          marketId: any(named: 'marketId'),
          onlyActive: any(named: 'onlyActive'),
          onlySupplyEnabled: any(named: 'onlySupplyEnabled'),
          onlyBorrowEnabled: any(named: 'onlyBorrowEnabled'),
          onlyCollateralEnabled: any(named: 'onlyCollateralEnabled'),
          search: any(named: 'search'),
        ),
      ).thenAnswer((_) async => _marketsResult());
      return _buildCubit(
        getProtocols: getProtocols,
        getNetworks: getNetworks,
        getMarkets: getMarkets,
        calculate: calculate,
      );
    },
    act: (cubit) => cubit.initialize(),
    verify: (cubit) {
      expect(cubit.state.selectedProtocol?.id, kHealthFactorAaveV3ProtocolId);
    },
  );

  blocTest<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
    'selectProtocol reloads networks and markets and clears result',
    build: () {
      _stubCatalogSuccess(
        getProtocols: getProtocols,
        getNetworks: getNetworks,
        getMarkets: getMarkets,
        protocolId: kHealthFactorAaveV3ProtocolId,
      );
      when(() => getNetworks.execute(protocol: 'other')).thenAnswer(
        (_) async => [const HealthFactorNetwork(id: '99', name: 'ethereum', chainId: 1)],
      );
      when(
        () => getMarkets.execute(
          protocol: 'other',
          network: 'ethereum',
          marketId: any(named: 'marketId'),
          onlyActive: any(named: 'onlyActive'),
          onlySupplyEnabled: any(named: 'onlySupplyEnabled'),
          onlyBorrowEnabled: any(named: 'onlyBorrowEnabled'),
          onlyCollateralEnabled: any(named: 'onlyCollateralEnabled'),
          search: any(named: 'search'),
        ),
      ).thenAnswer((_) async => _marketsResult(protocol: 'other', networkName: 'ethereum'));
      return _buildCubit(
        getProtocols: getProtocols,
        getNetworks: getNetworks,
        getMarkets: getMarkets,
        calculate: calculate,
      );
    },
    seed: () => HealthFactorCalculatorState(
      status: HealthFactorCalculatorStatus.result,
      protocols: const [
        HealthFactorProtocol(id: kHealthFactorAaveV3ProtocolId, name: 'Aave V3'),
        HealthFactorProtocol(id: 'other', name: 'Other'),
      ],
      selectedProtocol: const HealthFactorProtocol(id: kHealthFactorAaveV3ProtocolId, name: 'Aave V3'),
      selectedNetwork: _arbitrumNetwork(),
      market: _marketsResult(),
      result: _calculateResult(),
    ),
    act: (cubit) => cubit.selectProtocol(const HealthFactorProtocol(id: 'other', name: 'Other')),
    verify: (cubit) {
      expect(cubit.state.selectedProtocol?.id, 'other');
      expect(cubit.state.selectedNetwork?.name, 'ethereum');
      expect(cubit.state.result, isNull);
      expect(cubit.state.status, HealthFactorCalculatorStatus.ready);
    },
  );

  blocTest<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
    'selectNetwork reloads markets and resets rows',
    build: () {
      _stubCatalogSuccess(
        getProtocols: getProtocols,
        getNetworks: getNetworks,
        getMarkets: getMarkets,
      );
      when(
        () => getMarkets.execute(
          protocol: kHealthFactorAaveV3ProtocolId,
          network: 'ethereum',
          marketId: any(named: 'marketId'),
          onlyActive: any(named: 'onlyActive'),
          onlySupplyEnabled: any(named: 'onlySupplyEnabled'),
          onlyBorrowEnabled: any(named: 'onlyBorrowEnabled'),
          onlyCollateralEnabled: any(named: 'onlyCollateralEnabled'),
          search: any(named: 'search'),
        ),
      ).thenAnswer((_) async => _marketsResult(networkName: 'ethereum'));
      return _buildCubit(
        getProtocols: getProtocols,
        getNetworks: getNetworks,
        getMarkets: getMarkets,
        calculate: calculate,
      );
    },
    seed: () => HealthFactorCalculatorState(
      status: HealthFactorCalculatorStatus.ready,
      selectedProtocol: const HealthFactorProtocol(id: kHealthFactorAaveV3ProtocolId, name: 'Aave V3'),
      selectedNetwork: _arbitrumNetwork(),
      networks: [_arbitrumNetwork(), const HealthFactorNetwork(id: '1', name: 'ethereum', chainId: 1)],
      market: _marketsResult(),
      supplies: const [
        HealthFactorSupplyDraft(id: 'supply-1', assetId: '10', amount: '5'),
      ],
      borrows: const [],
      result: _calculateResult(),
    ),
    act: (cubit) => cubit.selectNetwork(const HealthFactorNetwork(id: '1', name: 'ethereum', chainId: 1)),
    verify: (cubit) {
      expect(cubit.state.selectedNetwork?.name, 'ethereum');
      expect(cubit.state.result, isNull);
      expect(cubit.state.supplies, hasLength(1));
      expect(cubit.state.supplies.single.amount, '');
      expect(cubit.state.borrows, hasLength(1));
    },
  );

  blocTest<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
    'add remove and update supply row keeps amount as string',
    build: () => _buildCubit(
      getProtocols: getProtocols,
      getNetworks: getNetworks,
      getMarkets: getMarkets,
      calculate: calculate,
    ),
    seed: () => _readySeed(),
    act: (cubit) async {
      final rowId = cubit.state.supplies.single.id;
      cubit.updateSupplyAsset(rowId, '11');
      cubit.updateSupplyAmount(rowId, '123.45');
      cubit.updateSupplyUseAsCollateral(rowId, false);
      cubit.addSupplyRow();
      cubit.removeSupplyRow(cubit.state.supplies.last.id);
    },
    verify: (cubit) {
      expect(cubit.state.supplies, hasLength(1));
      expect(cubit.state.supplies.single.assetId, '11');
      expect(cubit.state.supplies.single.amount, '123.45');
      expect(cubit.state.supplies.single.amount, isA<String>());
      expect(cubit.state.supplies.single.useAsCollateral, isFalse);
      expect(cubit.state.supplies.single.useMarketPrice, isTrue);
      expect(cubit.state.supplies.single.customPriceUsd, '');
    },
  );

  blocTest<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
    'add remove and update borrow row',
    build: () => _buildCubit(
      getProtocols: getProtocols,
      getNetworks: getNetworks,
      getMarkets: getMarkets,
      calculate: calculate,
    ),
    seed: () => _readySeed(),
    act: (cubit) async {
      cubit.updateBorrowAsset(cubit.state.borrows.single.id, '12');
      cubit.updateBorrowAmount(cubit.state.borrows.single.id, '0.5');
      cubit.addBorrowRow();
      final addedId = cubit.state.borrows.last.id;
      cubit.updateBorrowAsset(addedId, '99');
      cubit.removeBorrowRow(addedId);
    },
    verify: (cubit) {
      expect(cubit.state.borrows, hasLength(1));
      expect(cubit.state.borrows.single.assetId, '12');
      expect(cubit.state.borrows.single.amount, '0.5');
      expect(cubit.state.borrows.single.amount, isA<String>());
    },
  );

  blocTest<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
    'canCalculate is false for empty form',
    build: () => _buildCubit(
      getProtocols: getProtocols,
      getNetworks: getNetworks,
      getMarkets: getMarkets,
      calculate: calculate,
    ),
    seed: () => _readySeed(),
    verify: (cubit) {
      expect(cubit.state.canCalculate, isFalse);
    },
  );

  blocTest<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
    'calculate emits INVALID_FORM without backend call when form empty',
    build: () => _buildCubit(
      getProtocols: getProtocols,
      getNetworks: getNetworks,
      getMarkets: getMarkets,
      calculate: calculate,
    ),
    seed: () => _readySeed(),
    act: (cubit) => cubit.calculate(),
    verify: (cubit) {
      expect(cubit.state.status, HealthFactorCalculatorStatus.error);
      expect(cubit.state.errorCode, kHealthFactorCalculatorInvalidFormCode);
      verifyNever(() => calculate.execute(request: any(named: 'request')));
    },
  );

  blocTest<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
    'calculate uses network name and ignores empty rows',
    build: () {
      when(() => calculate.execute(request: any(named: 'request')))
          .thenAnswer((_) async => _calculateResult());
      return _buildCubit(
        getProtocols: getProtocols,
        getNetworks: getNetworks,
        getMarkets: getMarkets,
        calculate: calculate,
      );
    },
    seed: () => _readySeed(
      supplies: const [
        HealthFactorSupplyDraft(id: 's1'),
        HealthFactorSupplyDraft(id: 's2', assetId: '10', amount: '100'),
      ],
      borrows: const [
        HealthFactorBorrowDraft(id: 'b1', assetId: '12', amount: '50'),
        HealthFactorBorrowDraft(id: 'b2'),
      ],
    ),
    act: (cubit) => cubit.calculate(),
    verify: (cubit) {
      expect(cubit.state.status, HealthFactorCalculatorStatus.result);
      expect(cubit.state.result?.healthFactorDisplay, '1.73');

      final request = verify(() => calculate.execute(request: captureAny(named: 'request')))
          .captured
          .single as HealthFactorCalculateRequest;
      expect(request.network, 'arbitrum');
      expect(request.network, isNot(cubit.state.selectedNetwork!.id));
      expect(request.supplies, hasLength(1));
      expect(request.supplies.single.amount, '100');
      expect(request.borrows, hasLength(1));
      expect(request.borrows.single.amount, '50');
    },
  );

  blocTest<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
    'calculate error emits error with code and message',
    build: () {
      when(() => calculate.execute(request: any(named: 'request'))).thenAnswer(
        (_) async => throw const ApiError(
          message: 'Invalid position',
          code: 'INVALID_POSITION',
          statusCode: 400,
        ),
      );
      return _buildCubit(
        getProtocols: getProtocols,
        getNetworks: getNetworks,
        getMarkets: getMarkets,
        calculate: calculate,
      );
    },
    seed: () => _readySeed(
      supplies: const [HealthFactorSupplyDraft(id: 's1', assetId: '10', amount: '1')],
    ),
    act: (cubit) => cubit.calculate(),
    verify: (cubit) {
      expect(cubit.state.status, HealthFactorCalculatorStatus.ready);
      expect(cubit.state.errorCode, 'INVALID_POSITION');
      expect(cubit.state.errorMessage, 'Invalid position');
      expect(cubit.state.market, isNotNull);
    },
  );

  blocTest<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
    'calculate unauthenticated emits unauthenticated',
    build: () {
      when(() => calculate.execute(request: any(named: 'request'))).thenAnswer(
        (_) async => throw const ApiError(
          message: 'Login required',
          code: 'UNAUTHENTICATED',
          statusCode: 401,
        ),
      );
      return _buildCubit(
        getProtocols: getProtocols,
        getNetworks: getNetworks,
        getMarkets: getMarkets,
        calculate: calculate,
      );
    },
    seed: () => _readySeed(
      supplies: const [HealthFactorSupplyDraft(id: 's1', assetId: '10', amount: '1')],
    ),
    act: (cubit) => cubit.calculate(),
    verify: (cubit) {
      expect(cubit.state.status, HealthFactorCalculatorStatus.unauthenticated);
      expect(cubit.state.market, isNotNull);
    },
  );

  test('default draft rows use market price mode', () {
    final cubit = _buildCubit(
      getProtocols: getProtocols,
      getNetworks: getNetworks,
      getMarkets: getMarkets,
      calculate: calculate,
    );
    cubit.emit(_readySeed());
    expect(cubit.state.supplies.single.useMarketPrice, isTrue);
    expect(cubit.state.supplies.single.customPriceUsd, '');
    expect(cubit.state.borrows.single.useMarketPrice, isTrue);
    expect(cubit.state.borrows.single.customPriceUsd, '');
    cubit.close();
  });

  blocTest<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
    'updateSupplyUseMarketPrice and updateSupplyCustomPrice',
    build: () => _buildCubit(
      getProtocols: getProtocols,
      getNetworks: getNetworks,
      getMarkets: getMarkets,
      calculate: calculate,
    ),
    seed: () => _readySeed(
      supplies: const [
        HealthFactorSupplyDraft(id: 's1', assetId: '10', amount: '1'),
      ],
    ),
    act: (cubit) {
      cubit.updateSupplyUseMarketPrice('s1', false);
      cubit.updateSupplyCustomPrice('s1', '2500.5');
    },
    verify: (cubit) {
      expect(cubit.state.supplies.single.useMarketPrice, isFalse);
      expect(cubit.state.supplies.single.customPriceUsd, '2500.5');
      expect(cubit.state.supplies.single.customPriceUsd, isA<String>());
    },
  );

  blocTest<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
    'updateBorrowUseMarketPrice and updateBorrowCustomPrice',
    build: () => _buildCubit(
      getProtocols: getProtocols,
      getNetworks: getNetworks,
      getMarkets: getMarkets,
      calculate: calculate,
    ),
    seed: () => _readySeed(
      borrows: const [
        HealthFactorBorrowDraft(id: 'b1', assetId: '12', amount: '1'),
      ],
    ),
    act: (cubit) {
      cubit.updateBorrowUseMarketPrice('b1', false);
      cubit.updateBorrowCustomPrice('b1', '0.95');
    },
    verify: (cubit) {
      expect(cubit.state.borrows.single.useMarketPrice, isFalse);
      expect(cubit.state.borrows.single.customPriceUsd, '0.95');
    },
  );

  blocTest<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
    'calculate omits customPriceUsd when useMarketPrice is true',
    build: () {
      when(() => calculate.execute(request: any(named: 'request')))
          .thenAnswer((_) async => _calculateResult());
      return _buildCubit(
        getProtocols: getProtocols,
        getNetworks: getNetworks,
        getMarkets: getMarkets,
        calculate: calculate,
      );
    },
    seed: () => _readySeed(
      supplies: const [
        HealthFactorSupplyDraft(
          id: 's1',
          assetId: '10',
          amount: '1',
          useMarketPrice: true,
          customPriceUsd: '999',
        ),
      ],
    ),
    act: (cubit) => cubit.calculate(),
    verify: (_) {
      final request = verify(() => calculate.execute(request: captureAny(named: 'request')))
          .captured
          .single as HealthFactorCalculateRequest;
      expect(request.supplies.single.customPriceUsd, isNull);
    },
  );

  blocTest<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
    'calculate sends customPriceUsd when useMarketPrice is false',
    build: () {
      when(() => calculate.execute(request: any(named: 'request')))
          .thenAnswer((_) async => _calculateResult());
      return _buildCubit(
        getProtocols: getProtocols,
        getNetworks: getNetworks,
        getMarkets: getMarkets,
        calculate: calculate,
      );
    },
    seed: () => _readySeed(
      supplies: const [
        HealthFactorSupplyDraft(
          id: 's1',
          assetId: '10',
          amount: '1',
          useMarketPrice: false,
          customPriceUsd: '2500',
        ),
      ],
      borrows: const [
        HealthFactorBorrowDraft(
          id: 'b1',
          assetId: '12',
          amount: '50',
          useMarketPrice: false,
          customPriceUsd: '0.95',
        ),
      ],
    ),
    act: (cubit) => cubit.calculate(),
    verify: (_) {
      final request = verify(() => calculate.execute(request: captureAny(named: 'request')))
          .captured
          .single as HealthFactorCalculateRequest;
      expect(request.supplies.single.customPriceUsd, '2500');
      expect(request.borrows.single.customPriceUsd, '0.95');
    },
  );

  blocTest<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
    'calculate emits INVALID_FORM_CUSTOM_PRICE when custom mode without price',
    build: () => _buildCubit(
      getProtocols: getProtocols,
      getNetworks: getNetworks,
      getMarkets: getMarkets,
      calculate: calculate,
    ),
    seed: () => _readySeed(
      supplies: const [
        HealthFactorSupplyDraft(
          id: 's1',
          assetId: '10',
          amount: '1',
          useMarketPrice: false,
          customPriceUsd: '',
        ),
      ],
    ),
    act: (cubit) => cubit.calculate(),
    verify: (cubit) {
      expect(cubit.state.errorCode, kHealthFactorCalculatorInvalidFormCustomPriceCode);
      verifyNever(() => calculate.execute(request: any(named: 'request')));
    },
  );

  blocTest<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
    'changing supply asset resets custom price override',
    build: () => _buildCubit(
      getProtocols: getProtocols,
      getNetworks: getNetworks,
      getMarkets: getMarkets,
      calculate: calculate,
    ),
    seed: () => _readySeed(
      supplies: const [
        HealthFactorSupplyDraft(
          id: 's1',
          assetId: '10',
          amount: '1',
          useMarketPrice: false,
          customPriceUsd: '2500',
        ),
      ],
    ),
    act: (cubit) => cubit.updateSupplyAsset('s1', '11'),
    verify: (cubit) {
      expect(cubit.state.supplies.single.useMarketPrice, isTrue);
      expect(cubit.state.supplies.single.customPriceUsd, '');
    },
  );

  blocTest<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
    'marketPriceUsdForSupplyDraft reads reserve price',
    build: () => _buildCubit(
      getProtocols: getProtocols,
      getNetworks: getNetworks,
      getMarkets: getMarkets,
      calculate: calculate,
    ),
    seed: () => _readySeed(
      supplies: const [
        HealthFactorSupplyDraft(id: 's1', assetId: '10', amount: '1'),
      ],
    ),
    verify: (cubit) {
      expect(cubit.state.marketPriceUsdForSupplyDraft(cubit.state.supplies.single), '1');
      expect(cubit.state.reserveForAssetId('10')?.asset.symbol, 'SYM10');
    },
  );

  blocTest<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
    'calculate INVALID_CUSTOM_PRICE maps to error state',
    build: () {
      when(() => calculate.execute(request: any(named: 'request'))).thenAnswer(
        (_) async => throw const ApiError(
          message: 'Custom price must be positive',
          code: 'INVALID_CUSTOM_PRICE',
          statusCode: 400,
        ),
      );
      return _buildCubit(
        getProtocols: getProtocols,
        getNetworks: getNetworks,
        getMarkets: getMarkets,
        calculate: calculate,
      );
    },
    seed: () => _readySeed(
      supplies: const [
        HealthFactorSupplyDraft(
          id: 's1',
          assetId: '10',
          amount: '1',
          useMarketPrice: false,
          customPriceUsd: '0',
        ),
      ],
    ),
    act: (cubit) => cubit.calculate(),
    verify: (cubit) {
      expect(cubit.state.status, HealthFactorCalculatorStatus.ready);
      expect(cubit.state.errorCode, 'INVALID_CUSTOM_PRICE');
    },
  );

  blocTest<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
    'calculate DUPLICATE_POSITION_CUSTOM_PRICE_CONFLICT maps to error',
    build: () {
      when(() => calculate.execute(request: any(named: 'request'))).thenAnswer(
        (_) async => throw const ApiError(
          message: 'Conflicting custom prices',
          code: 'DUPLICATE_POSITION_CUSTOM_PRICE_CONFLICT',
          statusCode: 400,
        ),
      );
      return _buildCubit(
        getProtocols: getProtocols,
        getNetworks: getNetworks,
        getMarkets: getMarkets,
        calculate: calculate,
      );
    },
    seed: () => _readySeed(
      supplies: const [
        HealthFactorSupplyDraft(
          id: 's1',
          assetId: '10',
          amount: '1',
          useMarketPrice: false,
          customPriceUsd: '1',
        ),
      ],
    ),
    act: (cubit) => cubit.calculate(),
    verify: (cubit) {
      expect(cubit.state.errorCode, 'DUPLICATE_POSITION_CUSTOM_PRICE_CONFLICT');
    },
  );

  blocTest<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
    'refreshMarkets clears invalid selected asset ids',
    build: () {
      when(
        () => getMarkets.execute(
          protocol: kHealthFactorAaveV3ProtocolId,
          network: 'arbitrum',
          marketId: any(named: 'marketId'),
          onlyActive: any(named: 'onlyActive'),
          onlySupplyEnabled: any(named: 'onlySupplyEnabled'),
          onlyBorrowEnabled: any(named: 'onlyBorrowEnabled'),
          onlyCollateralEnabled: any(named: 'onlyCollateralEnabled'),
          search: any(named: 'search'),
        ),
      ).thenAnswer(
        (_) async => _marketsResult(reserveAssetIds: const ['10']),
      );
      return _buildCubit(
        getProtocols: getProtocols,
        getNetworks: getNetworks,
        getMarkets: getMarkets,
        calculate: calculate,
      );
    },
    seed: () => _readySeed(
      supplies: const [
        HealthFactorSupplyDraft(id: 's1', assetId: '10', amount: '1'),
        HealthFactorSupplyDraft(id: 's2', assetId: '99', amount: '2'),
      ],
      borrows: const [
        HealthFactorBorrowDraft(id: 'b1', assetId: 'gone', amount: '3'),
      ],
    ),
    act: (cubit) => cubit.refreshMarkets(),
    verify: (cubit) {
      expect(cubit.state.supplies[0].assetId, '10');
      expect(cubit.state.supplies[1].assetId, isNull);
      expect(cubit.state.borrows.single.assetId, isNull);
      expect(cubit.state.status, HealthFactorCalculatorStatus.ready);
    },
  );
}

void _stubCatalogSuccess({
  required MockGetHealthFactorProtocolsUseCase getProtocols,
  required MockGetHealthFactorNetworksUseCase getNetworks,
  required MockGetHealthFactorMarketsUseCase getMarkets,
  String protocolId = kHealthFactorAaveV3ProtocolId,
}) {
  when(() => getProtocols.execute()).thenAnswer(
    (_) async => [HealthFactorProtocol(id: protocolId, name: 'Aave V3')],
  );
  when(() => getNetworks.execute(protocol: protocolId)).thenAnswer(
    (_) async => [_arbitrumNetwork()],
  );
  when(
    () => getMarkets.execute(
      protocol: any(named: 'protocol'),
      network: any(named: 'network'),
      marketId: any(named: 'marketId'),
      onlyActive: any(named: 'onlyActive'),
      onlySupplyEnabled: any(named: 'onlySupplyEnabled'),
      onlyBorrowEnabled: any(named: 'onlyBorrowEnabled'),
      onlyCollateralEnabled: any(named: 'onlyCollateralEnabled'),
      search: any(named: 'search'),
    ),
  ).thenAnswer((invocation) async {
    final network = invocation.namedArguments[#network] as String;
    final protocol = invocation.namedArguments[#protocol] as String;
    return _marketsResult(protocol: protocol, networkName: network);
  });
}

HealthFactorNetwork _arbitrumNetwork() {
  return const HealthFactorNetwork(id: '2', name: 'arbitrum', chainId: 42161);
}

HealthFactorMarketsResult _marketsResult({
  String protocol = kHealthFactorAaveV3ProtocolId,
  String networkName = 'arbitrum',
  List<String> reserveAssetIds = const ['10', '12'],
}) {
  return HealthFactorMarketsResult(
    protocol: protocol,
    network: HealthFactorNetwork(
      id: networkName == 'ethereum' ? '1' : '2',
      name: networkName,
      chainId: networkName == 'ethereum' ? 1 : 42161,
    ),
    reserves: reserveAssetIds.map(_reserve).toList(growable: false),
  );
}

HealthFactorMarketReserve _reserve(String assetId) {
  return HealthFactorMarketReserve(
    protocol: kHealthFactorAaveV3ProtocolId,
    network: _arbitrumNetwork(),
    asset: HealthFactorAsset(
      id: assetId,
      symbol: 'SYM$assetId',
      name: 'Asset $assetId',
      address: '0x$assetId',
      decimals: 18,
    ),
    price: const HealthFactorPrice(usd: '1'),
    risk: const HealthFactorRisk(),
    flags: const HealthFactorFlags(
      supplyEnabled: true,
      borrowEnabled: true,
      collateralEnabled: true,
      isActive: true,
    ),
  );
}

HealthFactorCalculateResult _calculateResult() {
  return HealthFactorCalculateResult(
    protocol: kHealthFactorAaveV3ProtocolId,
    network: _arbitrumNetwork(),
    healthFactorDisplay: '1.73',
    riskLevel: 'high',
    totals: const HealthFactorTotals(
      collateralUsd: '100',
      collateralWeightedUsd: '80',
      borrowUsd: '50',
    ),
    positions: const HealthFactorPositionsBreakdown(),
  );
}

HealthFactorCalculatorState _readySeed({
  List<HealthFactorSupplyDraft>? supplies,
  List<HealthFactorBorrowDraft>? borrows,
}) {
  return HealthFactorCalculatorState(
    status: HealthFactorCalculatorStatus.ready,
    selectedProtocol: const HealthFactorProtocol(id: kHealthFactorAaveV3ProtocolId, name: 'Aave V3'),
    selectedNetwork: _arbitrumNetwork(),
    market: _marketsResult(),
    supplies: supplies ??
        const [HealthFactorSupplyDraft(id: 'seed-supply-1')],
    borrows: borrows ?? const [HealthFactorBorrowDraft(id: 'seed-borrow-1')],
  );
}

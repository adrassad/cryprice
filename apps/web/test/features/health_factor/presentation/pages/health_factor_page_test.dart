import 'dart:async';

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
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_warning.dart';
import 'package:cryprice_frontend/features/health_factor/domain/usecases/calculate_health_factor_usecase.dart';
import 'package:cryprice_frontend/features/health_factor/domain/usecases/get_health_factor_markets_usecase.dart';
import 'package:cryprice_frontend/features/health_factor/domain/usecases/get_health_factor_networks_usecase.dart';
import 'package:cryprice_frontend/features/health_factor/domain/usecases/get_health_factor_protocols_usecase.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/cubit/health_factor_calculator_cubit.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/cubit/health_factor_calculator_state.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/pages/health_factor_page.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/widgets/health_factor_result_card.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

class _TestHealthFactorCalculatorCubit extends HealthFactorCalculatorCubit {
  _TestHealthFactorCalculatorCubit()
      : super(
          getProtocolsUseCase: MockGetHealthFactorProtocolsUseCase(),
          getNetworksUseCase: MockGetHealthFactorNetworksUseCase(),
          getMarketsUseCase: MockGetHealthFactorMarketsUseCase(),
          calculateHealthFactorUseCase: MockCalculateHealthFactorUseCase(),
        );
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const HealthFactorCalculateRequest(protocol: 'aave_v3', network: 'arbitrum'),
    );
  });

  testWidgets('shows loading state', (tester) async {
    final cubit = _TestHealthFactorCalculatorCubit();
    addTearDown(cubit.close);
    cubit.emit(
      const HealthFactorCalculatorState(
        status: HealthFactorCalculatorStatus.loadingProtocols,
      ),
    );

    await tester.pumpWidget(_app(cubit));
    await tester.pump();

    expect(find.byKey(const Key('hf_calc_loading')), findsOneWidget);
    expect(find.text('Loading calculator…'), findsOneWidget);
  });

  testWidgets('shows ready form with protocol and network selectors', (tester) async {
    final cubit = _TestHealthFactorCalculatorCubit();
    addTearDown(cubit.close);
    cubit.emit(_readyState());

    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(cubit));
    await tester.pump();

    expect(find.byKey(const Key('hf_calc_form')), findsOneWidget);
    expect(find.text('Protocol'), findsOneWidget);
    expect(find.text('Network'), findsOneWidget);
    expect(find.text('Supply / Collateral'), findsOneWidget);
    expect(find.text('Borrow'), findsOneWidget);
  });

  testWidgets('add supply row calls cubit', (tester) async {
    final cubit = _TestHealthFactorCalculatorCubit();
    addTearDown(cubit.close);
    cubit.emit(_readyState());

    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(cubit));
    await tester.pump();

    final initialCount = cubit.state.supplies.length;
    await tester.tap(find.byKey(const Key('hf_calc_add_supply')));
    await tester.pump();

    expect(cubit.state.supplies.length, initialCount + 1);
  });

  testWidgets('add borrow row calls cubit', (tester) async {
    final cubit = _TestHealthFactorCalculatorCubit();
    addTearDown(cubit.close);
    cubit.emit(_readyState());

    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(cubit));
    await tester.pump();

    final initialCount = cubit.state.borrows.length;
    await tester.tap(find.byKey(const Key('hf_calc_add_borrow')));
    await tester.pump();

    expect(cubit.state.borrows.length, initialCount + 1);
  });

  testWidgets('calculate button disabled when canCalculate false', (tester) async {
    final cubit = _TestHealthFactorCalculatorCubit();
    addTearDown(cubit.close);
    cubit.emit(
      _readyState(
        supplies: const [HealthFactorSupplyDraft(id: 's1')],
        borrows: const [HealthFactorBorrowDraft(id: 'b1')],
      ),
    );

    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(cubit));
    await tester.pump();

    final button = tester.widget<FilledButton>(find.byKey(const Key('hf_calc_calculate')));
    expect(button.onPressed, isNull);
  });

  testWidgets('calculate button enabled and calls cubit when form valid', (tester) async {
    final calculate = MockCalculateHealthFactorUseCase();
    final cubit = HealthFactorCalculatorCubit(
      getProtocolsUseCase: MockGetHealthFactorProtocolsUseCase(),
      getNetworksUseCase: MockGetHealthFactorNetworksUseCase(),
      getMarketsUseCase: MockGetHealthFactorMarketsUseCase(),
      calculateHealthFactorUseCase: calculate,
    );
    addTearDown(cubit.close);
    when(() => calculate.execute(request: any(named: 'request'))).thenAnswer(
      (_) => Completer<HealthFactorCalculateResult>().future,
    );
    cubit.emit(
      _readyState(
        supplies: const [
          HealthFactorSupplyDraft(id: 's1', assetId: '10', amount: '1'),
        ],
      ),
    );

    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(cubit));
    await tester.pump();

    final button = tester.widget<FilledButton>(find.byKey(const Key('hf_calc_calculate')));
    expect(button.onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('hf_calc_calculate')));
    await tester.pump();

    expect(cubit.state.status, HealthFactorCalculatorStatus.calculating);
    verify(() => calculate.execute(request: any(named: 'request'))).called(1);
  });

  testWidgets('shows result card when result exists', (tester) async {
    final cubit = _TestHealthFactorCalculatorCubit();
    addTearDown(cubit.close);
    cubit.emit(
      _readyState().copyWith(
        status: HealthFactorCalculatorStatus.result,
        result: _sampleResult(),
      ),
    );

    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(cubit));
    await tester.pump();

    expect(find.byType(HealthFactorResultCard), findsOneWidget);
    expect(find.text('2.10'), findsOneWidget);
  });

  testWidgets('unauthenticated state renders message', (tester) async {
    final cubit = _TestHealthFactorCalculatorCubit();
    addTearDown(cubit.close);
    cubit.emit(
      const HealthFactorCalculatorState(
        status: HealthFactorCalculatorStatus.unauthenticated,
        errorCode: 'UNAUTHENTICATED',
        errorMessage: 'Login required',
      ),
    );

    await tester.pumpWidget(_app(cubit));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('hf_calc_unauthenticated')), findsOneWidget);
    expect(find.text('Session expired'), findsOneWidget);
    expect(find.text('Login required'), findsOneWidget);
  });

  testWidgets('error state renders retry', (tester) async {
    final cubit = _TestHealthFactorCalculatorCubit();
    addTearDown(cubit.close);
    cubit.emit(
      const HealthFactorCalculatorState(
        status: HealthFactorCalculatorStatus.error,
        errorCode: 'NETWORK',
        errorMessage: 'Network failed',
      ),
    );

    await tester.pumpWidget(_app(cubit));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('hf_calc_error')), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Network failed'), findsOneWidget);
  });
}

Widget _app(HealthFactorCalculatorCubit cubit) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<HealthFactorCalculatorCubit>.value(
      value: cubit,
      child: const Scaffold(body: HealthFactorPage()),
    ),
  );
}

HealthFactorCalculatorState _readyState({
  List<HealthFactorSupplyDraft>? supplies,
  List<HealthFactorBorrowDraft>? borrows,
}) {
  const protocol = HealthFactorProtocol(id: kHealthFactorAaveV3ProtocolId, name: 'Aave V3');
  const network = HealthFactorNetwork(id: '2', name: 'arbitrum', chainId: 42161);
  return HealthFactorCalculatorState(
    status: HealthFactorCalculatorStatus.ready,
    protocols: const [protocol],
    selectedProtocol: protocol,
    networks: const [network],
    selectedNetwork: network,
    market: HealthFactorMarketsResult(
      protocol: kHealthFactorAaveV3ProtocolId,
      network: network,
      reserves: [
        HealthFactorMarketReserve(
          protocol: kHealthFactorAaveV3ProtocolId,
          network: network,
          asset: const HealthFactorAsset(
            id: '10',
            symbol: 'USDC',
            name: 'USD Coin',
            address: '0x10',
            decimals: 6,
          ),
          price: const HealthFactorPrice(usd: '1'),
          risk: const HealthFactorRisk(),
          flags: const HealthFactorFlags(
            supplyEnabled: true,
            borrowEnabled: true,
            collateralEnabled: true,
            isActive: true,
          ),
        ),
      ],
    ),
    supplies: supplies ?? const [HealthFactorSupplyDraft(id: 'seed-supply')],
    borrows: borrows ?? const [HealthFactorBorrowDraft(id: 'seed-borrow')],
  );
}

HealthFactorCalculateResult _sampleResult() {
  return HealthFactorCalculateResult(
    protocol: kHealthFactorAaveV3ProtocolId,
    network: const HealthFactorNetwork(id: '2', name: 'arbitrum', chainId: 42161),
    healthFactorDisplay: '2.10',
    riskLevel: 'moderate',
    totals: const HealthFactorTotals(
      collateralUsd: '200',
      collateralWeightedUsd: '180',
      borrowUsd: '90',
    ),
    positions: const HealthFactorPositionsBreakdown(),
    warnings: const [
      HealthFactorWarning(code: 'NOTE', message: 'Estimate only'),
    ],
  );
}

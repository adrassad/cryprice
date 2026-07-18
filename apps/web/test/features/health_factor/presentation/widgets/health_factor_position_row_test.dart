import 'package:cryprice_frontend/core/widgets/token_icon.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_asset.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_flags.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_market_reserve.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_markets_result.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_network.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_price.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_risk.dart';
import 'package:cryprice_frontend/features/health_factor/domain/usecases/calculate_health_factor_usecase.dart';
import 'package:cryprice_frontend/features/health_factor/domain/usecases/get_health_factor_markets_usecase.dart';
import 'package:cryprice_frontend/features/health_factor/domain/usecases/get_health_factor_networks_usecase.dart';
import 'package:cryprice_frontend/features/health_factor/domain/usecases/get_health_factor_protocols_usecase.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/cubit/health_factor_calculator_cubit.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/cubit/health_factor_calculator_state.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/widgets/health_factor_position_row.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/widgets/health_factor_position_rows_section.dart';
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

class _TestCubit extends HealthFactorCalculatorCubit {
  _TestCubit()
      : super(
          getProtocolsUseCase: MockGetHealthFactorProtocolsUseCase(),
          getNetworksUseCase: MockGetHealthFactorNetworksUseCase(),
          getMarketsUseCase: MockGetHealthFactorMarketsUseCase(),
          calculateHealthFactorUseCase: MockCalculateHealthFactorUseCase(),
        );
}

void main() {
  testWidgets('market price visible when asset selected', (tester) async {
    await tester.pumpWidget(
      _wrap(
        HealthFactorPositionRow(
          reserves: [_reserve()],
          supplyDraft: const HealthFactorSupplyDraft(id: 's1', assetId: '10'),
          marketPriceUsd: '3500.5',
          callbacks: _noopCallbacks(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('hf_calc_current_price_s1')), findsOneWidget);
    expect(find.textContaining('\$3500.5'), findsOneWidget);
    expect(find.text('Price unavailable'), findsNothing);
  });

  testWidgets('shows price unavailable when market price missing', (tester) async {
    await tester.pumpWidget(
      _wrap(
        HealthFactorPositionRow(
          reserves: [_reserve()],
          supplyDraft: const HealthFactorSupplyDraft(id: 's1', assetId: '10'),
          marketPriceUsd: null,
          callbacks: _noopCallbacks(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Price unavailable'), findsOneWidget);
  });

  testWidgets('shows one token icon for selected asset only', (tester) async {
    await tester.pumpWidget(
      _wrap(
        HealthFactorPositionRow(
          reserves: [
            _reserve(),
            HealthFactorMarketReserve(
              protocol: kHealthFactorAaveV3ProtocolId,
              network: const HealthFactorNetwork(id: '2', name: 'arbitrum', chainId: 42161),
              asset: const HealthFactorAsset(
                id: '11',
                symbol: 'USDC',
                name: 'USDC',
                address: '0x11',
                decimals: 6,
                logoUrl: '/static/token-icons/42161/usdc.png',
              ),
              price: const HealthFactorPrice(usd: '1'),
              risk: HealthFactorRisk(),
              flags: HealthFactorFlags(
                supplyEnabled: true,
                borrowEnabled: true,
                collateralEnabled: true,
                isActive: true,
              ),
            ),
          ],
          supplyDraft: const HealthFactorSupplyDraft(id: 's1', assetId: '10'),
          marketPriceUsd: '3500.5',
          callbacks: _noopCallbacks(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(TokenIcon), findsOneWidget);
  });

  testWidgets('no token icon when asset not selected', (tester) async {
    await tester.pumpWidget(
      _wrap(
        HealthFactorPositionRow(
          reserves: [_reserve()],
          supplyDraft: const HealthFactorSupplyDraft(id: 's1'),
          marketPriceUsd: '1',
          callbacks: _noopCallbacks(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(TokenIcon), findsNothing);
    expect(find.byKey(const Key('hf_calc_current_price_s1')), findsNothing);
    expect(find.byKey(const Key('hf_calc_use_market_price_s1')), findsNothing);
  });

  testWidgets('custom price field hidden when use market price on', (tester) async {
    await tester.pumpWidget(
      _wrap(
        HealthFactorPositionRow(
          reserves: [_reserve()],
          supplyDraft: const HealthFactorSupplyDraft(
            id: 's1',
            assetId: '10',
            useMarketPrice: true,
          ),
          marketPriceUsd: '1',
          callbacks: _noopCallbacks(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('hf_calc_custom_price_s1')), findsNothing);
  });

  testWidgets('custom price field appears when use market price off', (tester) async {
    await tester.pumpWidget(
      _wrap(
        HealthFactorPositionRow(
          reserves: [_reserve()],
          supplyDraft: const HealthFactorSupplyDraft(
            id: 's1',
            assetId: '10',
            useMarketPrice: false,
            customPriceUsd: '2500',
          ),
          marketPriceUsd: '3500',
          callbacks: _noopCallbacks(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('hf_calc_custom_price_s1')), findsOneWidget);
    expect(find.text('Used for simulation only'), findsOneWidget);
  });

  testWidgets('toggle changes useMarketPrice via cubit', (tester) async {
    final cubit = _TestCubit();
    addTearDown(cubit.close);
    cubit.emit(_readyState(assetId: '10', priceUsd: '1'));

    await tester.pumpWidget(_app(cubit));
    await tester.pump();

    expect(cubit.state.supplies.single.useMarketPrice, isTrue);
    await tester.tap(find.byKey(const Key('hf_calc_use_market_price_s1')));
    await tester.pump();

    expect(cubit.state.supplies.single.useMarketPrice, isFalse);
  });

  testWidgets('typing custom price updates cubit', (tester) async {
    final cubit = _TestCubit();
    addTearDown(cubit.close);
    cubit.emit(
      _readyState(
        assetId: '10',
        priceUsd: '1',
        useMarketPrice: false,
        customPriceUsd: '',
      ),
    );

    await tester.pumpWidget(_app(cubit));
    await tester.pump();

    await tester.enterText(find.byKey(const Key('hf_calc_custom_price_s1')), '99.25');
    await tester.pump();

    expect(cubit.state.supplies.single.customPriceUsd, '99.25');
  });
}

HealthFactorPositionRowCallbacks _noopCallbacks() {
  return (
    onAssetChanged: (_) {},
    onAmountChanged: (_) {},
    onRemove: () {},
    onUseAsCollateralChanged: (_) {},
    onUseMarketPriceChanged: (_) {},
    onCustomPriceChanged: (_) {},
  );
}

HealthFactorMarketReserve _reserve({String priceUsd = '3500.5'}) {
  const network = HealthFactorNetwork(id: '2', name: 'arbitrum', chainId: 42161);
  return HealthFactorMarketReserve(
    protocol: kHealthFactorAaveV3ProtocolId,
    network: network,
    asset: const HealthFactorAsset(
      id: '10',
      symbol: 'WETH',
      name: 'WETH',
      address: '0x10',
      decimals: 18,
    ),
    price: HealthFactorPrice(usd: priceUsd),
    risk: const HealthFactorRisk(),
    flags: const HealthFactorFlags(
      supplyEnabled: true,
      borrowEnabled: true,
      collateralEnabled: true,
      isActive: true,
    ),
  );
}

HealthFactorCalculatorState _readyState({
  String? assetId,
  String priceUsd = '3500.5',
  bool useMarketPrice = true,
  String customPriceUsd = '',
}) {
  return HealthFactorCalculatorState(
    status: HealthFactorCalculatorStatus.ready,
    market: HealthFactorMarketsResult(
      protocol: kHealthFactorAaveV3ProtocolId,
      network: const HealthFactorNetwork(id: '2', name: 'arbitrum', chainId: 42161),
      reserves: [_reserve(priceUsd: priceUsd)],
    ),
    supplies: [
      HealthFactorSupplyDraft(
        id: 's1',
        assetId: assetId,
        useMarketPrice: useMarketPrice,
        customPriceUsd: customPriceUsd,
      ),
    ],
    borrows: const [HealthFactorBorrowDraft(id: 'b1')],
  );
}

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
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
      child: const Scaffold(
        body: HealthFactorPositionRowsSection(
          kind: HealthFactorPositionSectionKind.supply,
        ),
      ),
    ),
  );
}

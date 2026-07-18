import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_calculate_result.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_network.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_position_breakdown.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_totals.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/widgets/health_factor_result_card.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('result card displays health factor and totals', (tester) async {
    await tester.pumpWidget(
      _wrap(
        HealthFactorResultCard(
          result: HealthFactorCalculateResult(
            protocol: 'aave_v3',
            network: const HealthFactorNetwork(id: '2', name: 'arbitrum', chainId: 42161),
            healthFactorDisplay: '1.73',
            riskLevel: 'high',
            totals: const HealthFactorTotals(
              collateralUsd: '100',
              collateralWeightedUsd: '80',
              borrowUsd: '50',
            ),
            positions: const HealthFactorPositionsBreakdown(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1.73'), findsOneWidget);
    expect(find.textContaining('\$100'), findsOneWidget);
    expect(find.textContaining('\$80'), findsOneWidget);
    expect(find.textContaining('\$50'), findsOneWidget);
  });

  testWidgets('result card shows infinite symbol', (tester) async {
    await tester.pumpWidget(
      _wrap(
        HealthFactorResultCard(
          result: HealthFactorCalculateResult(
            protocol: 'aave_v3',
            network: const HealthFactorNetwork(id: '2', name: 'arbitrum', chainId: 42161),
            healthFactorDisplay: '∞',
            isInfinite: true,
            riskLevel: 'no_debt',
            totals: const HealthFactorTotals(
              collateralUsd: '0',
              collateralWeightedUsd: '0',
              borrowUsd: '0',
            ),
            positions: const HealthFactorPositionsBreakdown(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('∞'), findsOneWidget);
  });

  testWidgets('result card displays market and used price in breakdown', (tester) async {
    await tester.pumpWidget(
      _wrap(
        HealthFactorResultCard(
          result: HealthFactorCalculateResult(
            protocol: 'aave_v3',
            network: const HealthFactorNetwork(id: '2', name: 'arbitrum', chainId: 42161),
            healthFactorDisplay: '2',
            riskLevel: 'moderate',
            totals: const HealthFactorTotals(
              collateralUsd: '3750',
              collateralWeightedUsd: '3000',
              borrowUsd: '0',
            ),
            positions: const HealthFactorPositionsBreakdown(
              supplies: [
                HealthFactorPositionBreakdown(
                  symbol: 'WETH',
                  amount: '1.5',
                  marketPriceUsd: '3500.50',
                  priceUsd: '2500',
                  valueUsd: '3750',
                  priceSource: 'custom',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('WETH'), findsOneWidget);
    expect(find.textContaining('Amount: 1.5'), findsOneWidget);
    expect(find.textContaining('\$3500.50'), findsOneWidget);
    expect(find.textContaining('\$2500'), findsOneWidget);
    expect(find.textContaining('Value: \$3750'), findsOneWidget);
    expect(find.byKey(const Key('hf_price_source_badge_custom')), findsOneWidget);
    expect(find.text('Custom price'), findsOneWidget);
  });

  testWidgets('result card shows used price only for market source', (tester) async {
    await tester.pumpWidget(
      _wrap(
        HealthFactorResultCard(
          result: HealthFactorCalculateResult(
            protocol: 'aave_v3',
            network: const HealthFactorNetwork(id: '2', name: 'arbitrum', chainId: 42161),
            healthFactorDisplay: '2',
            riskLevel: 'moderate',
            totals: const HealthFactorTotals(
              collateralUsd: '5250',
              collateralWeightedUsd: '4200',
              borrowUsd: '0',
            ),
            positions: const HealthFactorPositionsBreakdown(
              supplies: [
                HealthFactorPositionBreakdown(
                  symbol: 'WETH',
                  amount: '1.5',
                  marketPriceUsd: '3500.50',
                  priceUsd: '3500.50',
                  valueUsd: '5250',
                  priceSource: 'market',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Market price:'), findsNothing);
    expect(find.textContaining('Used price:'), findsOneWidget);
    expect(find.textContaining('\$3500.50'), findsWidgets);
    expect(find.byKey(const Key('hf_price_source_badge_market')), findsOneWidget);
    expect(find.text('Market price'), findsOneWidget);
  });
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

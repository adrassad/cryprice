import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_protocol_summary_strip.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('protocol summary strip renders cards', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PortfolioProtocolSummaryStrip(
            portfolio: _portfolio(),
            selectedProtocol: PortfolioFilter.allProtocols,
            useCompactFilters: false,
          ),
        ),
      ),
    );

    expect(find.text('Protocols'), findsOneWidget);
    expect(find.text('All protocols'), findsOneWidget);
    expect(find.text('Wallet'), findsWidgets);
    expect(find.text('Aave V3'), findsWidgets);
  });
}

Portfolio _portfolio() {
  return Portfolio(
    summary: const PortfolioSummary(
      totalValueUsd: '300.00',
      walletsCount: 1,
      assetsCount: 1,
      networksCount: 1,
      updatedAt: '2026-05-19T13:30:00.000Z',
      netValueUsd: '300.00',
    ),
    networks: const [],
    protocolSummaries: const [
      PortfolioProtocolSummary(
        protocol: 'aave-v3',
        protocolName: 'Aave V3',
        category: 'lending',
        walletValueUsd: '0',
        suppliedValueUsd: '150.00',
        borrowedValueUsd: '40.00',
        grossValueUsd: '190.00',
        netValueUsd: '200.00',
        totalValueUsd: '200.00',
        healthFactor: '1.80',
        healthFactorStatus: PortfolioHealthFactorStatus.watch,
        healthFactorStatusLabel: 'Watch',
      ),
    ],
  );
}

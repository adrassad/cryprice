import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filtered_view.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_summary_card.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('overview shows net value and no_debt health factor', (tester) async {
    final portfolio = _portfolio(
      defiRisk: const PortfolioDefiRisk(
        healthFactor: PortfolioHealthFactor(
          value: null,
          status: PortfolioHealthFactorStatus.noDebt,
          statusLabel: null,
          protocol: 'aave-v3',
          protocolName: 'Aave V3',
          updatedAt: '2026-05-19T13:30:00.000Z',
          stale: false,
        ),
      ),
    );
    final filteredView = buildFilteredPortfolioView(
      portfolio,
      PortfolioFilter.allProtocols,
      PortfolioFilter.allWallets,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PortfolioSummaryCard(
            summary: portfolio.summary,
            filteredView: filteredView,
            selectedProtocol: PortfolioFilter.allProtocols,
            selectedWalletId: PortfolioFilter.allWallets,
            isRefreshing: false,
          ),
        ),
      ),
    );

    expect(find.text('Net value'), findsOneWidget);
    expect(find.text('\$300.00'), findsOneWidget);
    expect(find.text('No borrow risk'), findsOneWidget);
  });

  testWidgets('wallet protocol shows wallet headline and hides defi metrics', (
    tester,
  ) async {
    final portfolio = _portfolio();
    final filteredView = buildFilteredPortfolioView(
      portfolio,
      PortfolioFilter.walletProtocol,
      PortfolioFilter.allWallets,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PortfolioSummaryCard(
            summary: portfolio.summary,
            filteredView: filteredView,
            selectedProtocol: PortfolioFilter.walletProtocol,
            selectedWalletId: PortfolioFilter.allWallets,
            isRefreshing: false,
          ),
        ),
      ),
    );

    expect(find.text('On-chain value'), findsOneWidget);
    expect(find.text('\$100.00'), findsOneWidget);
    expect(find.text('Supplied value'), findsNothing);
    expect(find.text('Borrowed / debt'), findsNothing);
    expect(find.text('Health Factor'), findsNothing);
  });

  testWidgets('overview shows at_risk health factor label', (tester) async {
    final portfolio = _portfolio(
      defiRisk: const PortfolioDefiRisk(
        healthFactor: PortfolioHealthFactor(
          value: '1.05',
          status: PortfolioHealthFactorStatus.atRisk,
          statusLabel: 'At risk',
          protocol: 'aave-v3',
          protocolName: 'Aave V3',
          updatedAt: '2026-05-19T13:30:00.000Z',
          stale: false,
        ),
      ),
    );
    final filteredView = buildFilteredPortfolioView(
      portfolio,
      PortfolioFilter.allProtocols,
      PortfolioFilter.allWallets,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PortfolioSummaryCard(
            summary: portfolio.summary,
            filteredView: filteredView,
            selectedProtocol: PortfolioFilter.allProtocols,
            selectedWalletId: PortfolioFilter.allWallets,
            isRefreshing: false,
          ),
        ),
      ),
    );

    expect(find.text('At risk'), findsWidgets);
    expect(find.textContaining('1.05'), findsWidgets);
    expect(find.textContaining('HF updated:'), findsOneWidget);
  });

  testWidgets('overview shows health factor updated timestamp', (tester) async {
    final portfolio = _portfolio(
      defiRisk: const PortfolioDefiRisk(
        healthFactor: PortfolioHealthFactor(
          value: '1.61',
          status: PortfolioHealthFactorStatus.atRisk,
          statusLabel: 'At risk',
          protocol: 'aave-v3',
          protocolName: 'Aave V3',
          updatedAt: '2026-05-20T17:04:00.000Z',
          stale: true,
        ),
      ),
    );
    final filteredView = buildFilteredPortfolioView(
      portfolio,
      PortfolioFilter.allProtocols,
      PortfolioFilter.allWallets,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PortfolioSummaryCard(
            summary: portfolio.summary,
            filteredView: filteredView,
            selectedProtocol: PortfolioFilter.allProtocols,
            selectedWalletId: PortfolioFilter.allWallets,
            isRefreshing: false,
          ),
        ),
      ),
    );

    expect(find.textContaining('HF updated:'), findsOneWidget);
    expect(find.text('Stale data'), findsNothing);
  });
}

Portfolio _portfolio({PortfolioDefiRisk defiRisk = const PortfolioDefiRisk()}) {
  return Portfolio(
    summary: const PortfolioSummary(
      totalValueUsd: '300.00',
      walletsCount: 1,
      assetsCount: 1,
      networksCount: 1,
      updatedAt: '2026-05-19T13:30:00.000Z',
      netValueUsd: '300.00',
      walletValueUsd: '100.00',
      suppliedValueUsd: '150.00',
      borrowedValueUsd: '40.00',
      grossValueUsd: '290.00',
    ),
    networks: const [],
    totals: const PortfolioTotals(
      netValueUsd: '300.00',
      walletValueUsd: '100.00',
      suppliedValueUsd: '150.00',
      borrowedValueUsd: '40.00',
      grossValueUsd: '290.00',
    ),
    defiRisk: defiRisk,
  );
}

import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filtered_view.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/utils/portfolio_overview_display.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_formatters.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Future<AppLocalizations> _loadLoc(WidgetTester tester) async {
  late AppLocalizations loc;
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Builder(
        builder: (context) {
          loc = AppLocalizations.of(context)!;
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return loc;
}

void main() {
  group('PortfolioOverviewDisplay', () {
    testWidgets('all/all uses portfolio totals and defiRisk health factor', (
      tester,
    ) async {
      final loc = await _loadLoc(tester);
      final portfolio = _portfolio();
      final view = buildFilteredPortfolioView(
        portfolio,
        PortfolioFilter.allProtocols,
        PortfolioFilter.allWallets,
      );
      final overview = PortfolioOverviewDisplay.fromFilters(
        filteredView: view,
        selectedProtocol: PortfolioFilter.allProtocols,
        selectedWalletId: PortfolioFilter.allWallets,
        loc: loc,
      );

      expect(overview.scope, PortfolioOverviewScope.allPortfolio);
      expect(overview.netValueUsd, '300.00');
      expect(overview.primaryValueUsd, '300.00');
      expect(overview.walletValueUsd, '110.00');
      expect(overview.suppliedValueUsd, '150.00');
      expect(overview.borrowedValueUsd, '40.00');
      expect(overview.grossValueUsd, '260.00');
      expect(overview.showSuppliedMetric, isTrue);
      expect(overview.showBorrowedMetric, isTrue);
      expect(overview.healthFactor?.value, '2.00');
      expect(overview.healthFactor?.status, PortfolioHealthFactorStatus.safe);
      expect(view.totalsSource, PortfolioFilteredTotalsSource.portfolioTotals);
    });

    testWidgets('wallet protocol emphasizes wallet value and hides defi metrics', (
      tester,
    ) async {
      final loc = await _loadLoc(tester);
      final view = buildFilteredPortfolioView(
        _portfolio(),
        PortfolioFilter.walletProtocol,
        PortfolioFilter.allWallets,
      );
      final overview = PortfolioOverviewDisplay.fromFilters(
        filteredView: view,
        selectedProtocol: PortfolioFilter.walletProtocol,
        selectedWalletId: PortfolioFilter.allWallets,
        loc: loc,
      );

      expect(overview.scope, PortfolioOverviewScope.walletProtocol);
      expect(overview.primaryValueUsd, '110.00');
      expect(overview.showHealthFactor, isFalse);
      expect(overview.showWalletMetric, isFalse);
      expect(overview.showSuppliedMetric, isFalse);
      expect(overview.showBorrowedMetric, isFalse);
      expect(overview.showGrossMetric, isFalse);
      expect(view.overviewHealthFactorStatus, PortfolioHealthFactorStatus.none);
    });

    testWidgets('aave protocol uses protocol summary totals', (tester) async {
      final loc = await _loadLoc(tester);
      final view = buildFilteredPortfolioView(
        _portfolio(),
        'aave-v3',
        PortfolioFilter.allWallets,
      );
      final overview = PortfolioOverviewDisplay.fromFilters(
        filteredView: view,
        selectedProtocol: 'aave-v3',
        selectedWalletId: PortfolioFilter.allWallets,
        loc: loc,
      );

      expect(overview.scope, PortfolioOverviewScope.specificProtocol);
      expect(overview.netValueUsd, '200.00');
      expect(overview.suppliedValueUsd, '150.00');
      expect(overview.showWalletMetric, isFalse);
      expect(overview.healthFactor?.value, '1.80');
      expect(
        overview.healthFactor?.status,
        PortfolioHealthFactorStatus.watch,
      );
    });

    testWidgets('selected wallet uses wallet summary totals', (tester) async {
      final loc = await _loadLoc(tester);
      final view = buildFilteredPortfolioView(
        _portfolio(),
        PortfolioFilter.allProtocols,
        '1',
      );
      final overview = PortfolioOverviewDisplay.fromFilters(
        filteredView: view,
        selectedProtocol: PortfolioFilter.allProtocols,
        selectedWalletId: '1',
        loc: loc,
      );

      expect(overview.scope, PortfolioOverviewScope.walletFilter);
      expect(overview.netValueUsd, '100.00');
      expect(overview.walletValueUsd, '10.00');
      expect(overview.healthFactor?.value, '1.50');
      expect(overview.scopeHint, loc.portfolioOverviewScopeWalletFilter);
    });

    testWidgets('aave plus wallet prefers protocol HF with wallet totals', (
      tester,
    ) async {
      final loc = await _loadLoc(tester);
      final view = buildFilteredPortfolioView(
        _portfolio(),
        'aave-v3',
        '1',
      );
      final overview = PortfolioOverviewDisplay.fromFilters(
        filteredView: view,
        selectedProtocol: 'aave-v3',
        selectedWalletId: '1',
        loc: loc,
      );

      expect(overview.scope, PortfolioOverviewScope.protocolAndWallet);
      expect(overview.netValueUsd, '100.00');
      expect(view.totalsSource, PortfolioFilteredTotalsSource.walletSummary);
      expect(overview.healthFactor?.value, '1.80');
      expect(overview.scopeHint, loc.portfolioOverviewScopeProtocolWallet);
    });

    testWidgets('protocol summary no_debt status shows in overview HF', (
      tester,
    ) async {
      final loc = await _loadLoc(tester);
      final portfolio = _portfolio(
        protocolSummaries: const <PortfolioProtocolSummary>[
          PortfolioProtocolSummary(
            protocol: 'aave-v3',
            protocolName: 'Aave V3',
            category: 'lending',
            walletValueUsd: null,
            suppliedValueUsd: '150.00',
            borrowedValueUsd: null,
            grossValueUsd: '150.00',
            netValueUsd: '150.00',
            totalValueUsd: '150.00',
            healthFactor: null,
            healthFactorStatus: PortfolioHealthFactorStatus.noDebt,
            healthFactorStatusLabel: null,
          ),
        ],
      );
      final view = buildFilteredPortfolioView(
        portfolio,
        'aave-v3',
        PortfolioFilter.allWallets,
      );
      final overview = PortfolioOverviewDisplay.fromFilters(
        filteredView: view,
        selectedProtocol: 'aave-v3',
        selectedWalletId: PortfolioFilter.allWallets,
        loc: loc,
      );

      expect(overview.healthFactor?.status, PortfolioHealthFactorStatus.noDebt);
    });

    test('strips leading minus from borrowed display value', () {
      expect(positiveFinancialDisplayValue('-40.00'), '40.00');
      expect(positiveFinancialDisplayValue('40.00'), '40.00');
    });
  });
}

Portfolio _portfolio({
  List<PortfolioProtocolSummary> protocolSummaries = const <PortfolioProtocolSummary>[
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
}) {
  return Portfolio(
    summary: const PortfolioSummary(
      totalValueUsd: '300.00',
      walletsCount: 2,
      assetsCount: 2,
      networksCount: 1,
      updatedAt: '2026-05-19T13:30:00.000Z',
      netValueUsd: '299.00',
      walletValueUsd: '100.00',
      suppliedValueUsd: '140.00',
      borrowedValueUsd: '35.00',
      grossValueUsd: '250.00',
    ),
    totals: const PortfolioTotals(
      netValueUsd: '300.00',
      walletValueUsd: '110.00',
      suppliedValueUsd: '150.00',
      borrowedValueUsd: '40.00',
      grossValueUsd: '260.00',
    ),
    defiRisk: const PortfolioDefiRisk(
      healthFactor: PortfolioHealthFactor(
        value: '2.00',
        status: PortfolioHealthFactorStatus.safe,
        statusLabel: 'Safe',
        protocol: 'aave-v3',
        protocolName: 'Aave V3',
        updatedAt: '2026-05-19T13:30:00.000Z',
        stale: false,
      ),
    ),
    wallets: const <PortfolioWalletSummary>[
      PortfolioWalletSummary(
        walletId: '1',
        walletAddress: '0xwallet1',
        walletLabel: 'Main',
        walletValueUsd: '10.00',
        suppliedValueUsd: '70.00',
        borrowedValueUsd: '20.00',
        grossValueUsd: '80.00',
        netValueUsd: '100.00',
        healthFactor: '1.50',
        healthFactorStatus: PortfolioHealthFactorStatus.safe,
        healthFactorStatusLabel: 'Safe',
      ),
    ],
    protocolSummaries: protocolSummaries,
    networks: const <PortfolioNetwork>[],
  );
}

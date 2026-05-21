import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_allocation.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_allocation_section.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('allocation section renders at top with assets mode', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PortfolioAllocationSection(
            portfolio: _portfolio(),
            selectedWalletId: PortfolioFilter.allWallets,
          ),
        ),
      ),
    );

    expect(find.text('Allocation'), findsOneWidget);
    expect(find.text('USDC'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(find.text('\$600.00'), findsOneWidget);
  });

  testWidgets('mode chips switch to debts', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PortfolioAllocationSection(
            portfolio: _portfolio(),
            selectedWalletId: PortfolioFilter.allWallets,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Debts'));
    await tester.pumpAndSettle();

    expect(find.text('USDC debt'), findsOneWidget);
    expect(find.text('\$100.00'), findsOneWidget);
  });

  testWidgets('selected wallet changes chart data', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PortfolioAllocationSection(
            portfolio: _portfolio(),
            selectedWalletId: '4',
          ),
        ),
      ),
    );

    expect(find.text('ETH'), findsOneWidget);
    expect(find.text('USDC'), findsNothing);
  });

  testWidgets('empty wallet debts shows no debt positions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PortfolioAllocationSection(
            portfolio: _portfolio(),
            selectedWalletId: '4',
          ),
        ),
      ),
    );

    await tester.tap(find.text('Debts'));
    await tester.pumpAndSettle();

    expect(find.text('No debt positions'), findsOneWidget);
  });

  testWidgets('hides section when allocation is missing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PortfolioAllocationSection(
            portfolio: Portfolio(
              summary: _portfolio().summary,
              networks: const [],
            ),
            selectedWalletId: PortfolioFilter.allWallets,
          ),
        ),
      ),
    );

    expect(find.text('Allocation'), findsNothing);
  });
}

Portfolio _portfolio() {
  return Portfolio(
    summary: const PortfolioSummary(
      totalValueUsd: '1000.00',
      walletsCount: 2,
      assetsCount: 2,
      networksCount: 1,
      updatedAt: '2026-05-19T13:30:00.000Z',
    ),
    networks: const [],
    allocation: PortfolioAllocation(
      assets: const [
        PortfolioAllocationItem(
          key: 'usdc',
          label: 'USDC',
          valueUsd: '600.00',
          percentage: '60',
        ),
      ],
      debts: const [
        PortfolioAllocationItem(
          key: 'debt-usdc',
          label: 'USDC debt',
          valueUsd: '100.00',
          percentage: '100',
        ),
      ],
      protocols: const [
        PortfolioAllocationItem(
          key: 'aave-v3',
          label: 'Aave V3',
          valueUsd: '700.00',
          percentage: '70',
        ),
      ],
      networks: const [
        PortfolioAllocationItem(
          key: 'ethereum',
          label: 'Ethereum',
          valueUsd: '900.00',
          percentage: '90',
        ),
      ],
      wallets: const [
        PortfolioWalletAllocation(
          walletId: '4',
          walletAddress: '0xabc',
          walletLabel: 'TW',
          assets: [
            PortfolioAllocationItem(
              key: 'eth',
              label: 'ETH',
              valueUsd: '400.00',
              percentage: '100',
            ),
          ],
          debts: [],
          protocols: [],
          networks: [],
        ),
      ],
    ),
  );
}

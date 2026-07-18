import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_wallet_selector.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('wallet selector renders all wallets and wallet chips', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PortfolioWalletSelector(
            portfolio: _portfolio(),
            selectedWalletId: PortfolioFilter.allWallets,
            useCompactFilters: false,
          ),
        ),
      ),
    );

    expect(find.text('All addresses'), findsOneWidget);
    expect(find.text('Main'), findsOneWidget);
    expect(find.text('Secondary'), findsOneWidget);
  });
}

Portfolio _portfolio() {
  return Portfolio(
    summary: const PortfolioSummary(
      totalValueUsd: '300.00',
      walletsCount: 2,
      assetsCount: 1,
      networksCount: 1,
      updatedAt: '2026-05-19T13:30:00.000Z',
      netValueUsd: '300.00',
    ),
    networks: const [],
    wallets: const [
      PortfolioWalletSummary(
        walletId: '1',
        walletAddress: '0xwallet1',
        walletLabel: 'Main',
        walletValueUsd: '100.00',
        suppliedValueUsd: null,
        borrowedValueUsd: null,
        grossValueUsd: null,
        netValueUsd: '100.00',
        healthFactor: null,
        healthFactorStatus: null,
        healthFactorStatusLabel: null,
      ),
      PortfolioWalletSummary(
        walletId: '2',
        walletAddress: '0xwallet2',
        walletLabel: 'Secondary',
        walletValueUsd: '200.00',
        suppliedValueUsd: null,
        borrowedValueUsd: null,
        grossValueUsd: null,
        netValueUsd: '200.00',
        healthFactor: null,
        healthFactorStatus: null,
        healthFactorStatusLabel: null,
      ),
    ],
  );
}

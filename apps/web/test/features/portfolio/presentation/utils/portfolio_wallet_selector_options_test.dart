import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_price_status.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/utils/portfolio_wallet_selector_options.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('builds options from wallet summaries', (tester) async {
    late AppLocalizations loc;
    await tester.pumpWidget(_localizationHarness(onBuilt: (l) => loc = l));

    final options = buildPortfolioWalletSelectorOptions(
      portfolio: _portfolioWithSummaries(),
      loc: loc,
    );

    expect(options, hasLength(3));
    expect(options.first.walletId, PortfolioFilter.allWallets);
    expect(options.first.title, 'All addresses');
    expect(options[1].title, 'Main');
    expect(options[1].netValueUsd, '100.00');
    expect(options[2].title, 'Secondary');
  });

  testWidgets('derives wallets without label using shortened address', (
    tester,
  ) async {
    late AppLocalizations loc;
    await tester.pumpWidget(_localizationHarness(onBuilt: (l) => loc = l));

    final options = buildPortfolioWalletSelectorOptions(
      portfolio: _portfolioDerived(),
      loc: loc,
    );

    expect(options, hasLength(2));
    expect(options.last.walletId, 'wallet-2');
    expect(options.last.title, '0xabcd...ef01');
    expect(options.last.netValueUsd, isNull);
  });

  testWidgets('returns empty options when no wallets can be derived', (
    tester,
  ) async {
    late AppLocalizations loc;
    await tester.pumpWidget(_localizationHarness(onBuilt: (l) => loc = l));

    final options = buildPortfolioWalletSelectorOptions(
      portfolio: const Portfolio(
        summary: PortfolioSummary(
          totalValueUsd: '0',
          walletsCount: 0,
          assetsCount: 0,
          networksCount: 0,
          updatedAt: '2026-05-19T13:30:00.000Z',
        ),
        networks: <PortfolioNetwork>[],
      ),
      loc: loc,
    );

    expect(options, isEmpty);
  });
}

Widget _localizationHarness({required void Function(AppLocalizations loc) onBuilt}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Builder(
      builder: (context) {
        onBuilt(AppLocalizations.of(context)!);
        return const SizedBox.shrink();
      },
    ),
  );
}

Portfolio _portfolioWithSummaries() {
  return const Portfolio(
    summary: PortfolioSummary(
      totalValueUsd: '300.00',
      walletsCount: 2,
      assetsCount: 1,
      networksCount: 1,
      updatedAt: '2026-05-19T13:30:00.000Z',
      netValueUsd: '300.00',
    ),
    networks: <PortfolioNetwork>[],
    wallets: <PortfolioWalletSummary>[
      PortfolioWalletSummary(
        walletId: '1',
        walletAddress: '0xwallet1',
        walletLabel: 'Main',
        walletValueUsd: '10.00',
        suppliedValueUsd: null,
        borrowedValueUsd: null,
        grossValueUsd: '10.00',
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
        grossValueUsd: '200.00',
        netValueUsd: '200.00',
        healthFactor: null,
        healthFactorStatus: null,
        healthFactorStatusLabel: null,
      ),
    ],
  );
}

Portfolio _portfolioDerived() {
  return Portfolio(
    summary: const PortfolioSummary(
      totalValueUsd: '100.00',
      walletsCount: 1,
      assetsCount: 1,
      networksCount: 0,
      updatedAt: '2026-05-19T13:30:00.000Z',
      netValueUsd: '100.00',
    ),
    networks: const <PortfolioNetwork>[],
    walletHoldings: const <PortfolioHolding>[
      PortfolioHolding(
        kind: 'wallet',
        networkId: 1,
        network: 'ethereum',
        networkName: 'Ethereum',
        chainId: 1,
        assetId: '10',
        assetSymbol: 'ETH',
        assetAddress: '0x0',
        symbol: 'ETH',
        address: '0x0',
        amount: '1.0',
        balanceRaw: '0',
        decimals: 18,
        priceUsd: '100.00',
        valueUsd: '100.00',
        priceStatus: PortfolioPriceStatus.ok,
        wallets: <PortfolioWalletBreakdown>[
          PortfolioWalletBreakdown(
            walletId: 'wallet-2',
            address: '0xabcdefabcdefabcdefabcdefabcdefabcdef01',
            label: null,
            walletAddress: '0xabcdefabcdefabcdefabcdefabcdefabcdef01',
            walletLabel: null,
            amount: '1.0',
            balanceRaw: '0',
            balance: '1.0',
            valueUsd: null,
            syncedAt: null,
            blockNumber: null,
          ),
        ],
      ),
    ],
  );
}

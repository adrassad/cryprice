import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_price_status.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/utils/portfolio_protocol_summary_options.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('builds options from protocolSummaries', (tester) async {
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

    final options = buildPortfolioProtocolStripOptions(
      portfolio: _portfolioWithSummaries(),
      loc: loc,
    );

    expect(options, hasLength(3));
    expect(options.first.protocolId, PortfolioFilter.allProtocols);
    expect(options[1].protocolId, PortfolioFilter.walletProtocol);
    expect(options.last.protocolId, 'aave-v3');
    expect(options.last.valueUsd, '200.00');
    expect(options.last.healthFactorStatus, PortfolioHealthFactorStatus.watch);
    expect(
      options.map((option) => option.protocolId).toList(),
      hasLength(options.map((option) => option.protocolId).toSet().length),
    );
  });

  testWidgets('wallet strip uses wallet protocol summary value when present', (
    tester,
  ) async {
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

    final options = buildPortfolioProtocolStripOptions(
      portfolio: _portfolioWithSummaries(
        protocolSummaries: const <PortfolioProtocolSummary>[
          PortfolioProtocolSummary(
            protocol: PortfolioFilter.walletProtocol,
            protocolName: 'Wallet',
            category: 'wallet',
            walletValueUsd: '88.00',
            suppliedValueUsd: null,
            borrowedValueUsd: null,
            grossValueUsd: '88.00',
            netValueUsd: '88.00',
            totalValueUsd: '88.00',
            healthFactor: null,
            healthFactorStatus: PortfolioHealthFactorStatus.none,
            healthFactorStatusLabel: null,
          ),
          PortfolioProtocolSummary(
            protocol: 'aave-v3',
            protocolName: 'Aave V3',
            category: 'lending',
            walletValueUsd: null,
            suppliedValueUsd: '200.00',
            borrowedValueUsd: null,
            grossValueUsd: '200.00',
            netValueUsd: '200.00',
            totalValueUsd: '200.00',
            healthFactor: '1.80',
            healthFactorStatus: PortfolioHealthFactorStatus.watch,
            healthFactorStatusLabel: 'Watch',
          ),
        ],
      ),
      loc: loc,
    );

    expect(options[1].protocolId, PortfolioFilter.walletProtocol);
    expect(options[1].valueUsd, '88.00');
  });

  testWidgets('excludes backend wallet protocol summary from strip options', (
    tester,
  ) async {
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

    final options = buildPortfolioProtocolStripOptions(
      portfolio: _portfolioWithSummaries(
        protocolSummaries: const <PortfolioProtocolSummary>[
          PortfolioProtocolSummary(
            protocol: PortfolioFilter.walletProtocol,
            protocolName: 'Wallet bucket',
            category: 'wallet',
            walletValueUsd: '99.00',
            suppliedValueUsd: null,
            borrowedValueUsd: null,
            grossValueUsd: '99.00',
            netValueUsd: '99.00',
            totalValueUsd: '99.00',
            healthFactor: null,
            healthFactorStatus: PortfolioHealthFactorStatus.none,
            healthFactorStatusLabel: null,
          ),
          PortfolioProtocolSummary(
            protocol: 'aave-v3',
            protocolName: 'Aave V3',
            category: 'lending',
            walletValueUsd: null,
            suppliedValueUsd: '200.00',
            borrowedValueUsd: null,
            grossValueUsd: '200.00',
            netValueUsd: '200.00',
            totalValueUsd: '200.00',
            healthFactor: '1.80',
            healthFactorStatus: PortfolioHealthFactorStatus.watch,
            healthFactorStatusLabel: 'Watch',
          ),
        ],
      ),
      loc: loc,
    );

    final protocolIds = options.map((option) => option.protocolId).toList();

    expect(options, hasLength(3));
    expect(protocolIds.where((id) => id == PortfolioFilter.walletProtocol), hasLength(1));
    expect(protocolIds, contains('aave-v3'));
    expect(protocolIds, hasLength(protocolIds.toSet().length));
  });

  testWidgets('builds fallback options without protocolSummaries', (tester) async {
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

    final options = buildPortfolioProtocolStripOptions(
      portfolio: _portfolioFallback(),
      loc: loc,
    );

    expect(options.map((option) => option.protocolId).toList(), [
      PortfolioFilter.allProtocols,
      PortfolioFilter.walletProtocol,
      'aave-v3',
    ]);
    expect(options.last.valueUsd, isNull);
  });
}

Portfolio _portfolioWithSummaries({
  List<PortfolioProtocolSummary> protocolSummaries = const <PortfolioProtocolSummary>[
    PortfolioProtocolSummary(
      protocol: 'aave-v3',
      protocolName: 'Aave V3',
      category: 'lending',
      walletValueUsd: null,
      suppliedValueUsd: '200.00',
      borrowedValueUsd: null,
      grossValueUsd: '200.00',
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
      walletsCount: 1,
      assetsCount: 1,
      networksCount: 1,
      updatedAt: '2026-05-19T13:30:00.000Z',
      netValueUsd: '300.00',
      walletValueUsd: '100.00',
    ),
    networks: const <PortfolioNetwork>[],
    protocolSummaries: protocolSummaries,
  );
}

Portfolio _portfolioFallback() {
  return Portfolio(
    summary: const PortfolioSummary(
      totalValueUsd: '100.00',
      walletsCount: 1,
      assetsCount: 1,
      networksCount: 1,
      updatedAt: '2026-05-19T13:30:00.000Z',
      netValueUsd: '100.00',
      walletValueUsd: '50.00',
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
        priceUsd: '50.00',
        valueUsd: '50.00',
        priceStatus: PortfolioPriceStatus.ok,
      ),
    ],
    protocolPositions: PortfolioProtocolPositions(
      supplied: [
        PortfolioProtocolPosition(
          kind: 'protocol',
          protocol: 'aave-v3',
          protocolName: 'Aave V3',
          networkId: 1,
          network: 'ethereum',
          networkName: 'Ethereum',
          chainId: 1,
          positionSide: PortfolioPositionSide.supplied,
          tokenRole: 'collateral',
          debtType: null,
          underlyingSymbol: 'USDC',
          underlyingAddress: '0x0',
          tokenSymbol: 'aUSDC',
          tokenAddress: '0x0',
          amount: '1',
          balanceRaw: null,
          decimals: 6,
          priceUsd: '1.00',
          valueUsd: '50.00',
          priceStatus: PortfolioPriceStatus.ok,
        ),
      ],
    ),
  );
}

import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_price_status.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filtered_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildFilteredPortfolioView', () {
    test('default filters expose full portfolio', () {
      final portfolio = _filterablePortfolio();
      final view = buildFilteredPortfolioView(
        portfolio,
        PortfolioFilter.allProtocols,
        PortfolioFilter.allWallets,
      );

      expect(view.visibleWalletHoldings, hasLength(1));
      expect(view.visibleSuppliedPositions, hasLength(2));
      expect(view.visibleBorrowedPositions, hasLength(1));
      expect(view.visiblePositionsHealth, hasLength(2));
      expect(view.visibleProtocolSummaries, hasLength(1));
      expect(view.visibleWallets, hasLength(2));
      expect(view.hasVisibleWalletHoldings, isTrue);
      expect(view.hasVisibleDefiPositions, isTrue);
      expect(view.scopeNetValueUsd, '300.00');
      expect(view.totalsSource, PortfolioFilteredTotalsSource.portfolioSummary);
      expect(view.selectedWalletSummary, isNull);
      expect(view.selectedProtocolSummary, isNull);
    });

    test('wallet protocol hides defi positions and protocol summaries', () {
      final view = buildFilteredPortfolioView(
        _filterablePortfolio(),
        PortfolioFilter.walletProtocol,
        PortfolioFilter.allWallets,
      );

      expect(view.visibleWalletHoldings, hasLength(1));
      expect(view.visibleSuppliedPositions, isEmpty);
      expect(view.visibleBorrowedPositions, isEmpty);
      expect(view.visiblePositionsHealth, isEmpty);
      expect(view.visibleProtocolSummaries, isEmpty);
      expect(view.hasVisibleDefiPositions, isFalse);
      expect(view.overviewHealthFactorStatus, PortfolioHealthFactorStatus.none);
    });

    test('specific protocol hides wallet holdings', () {
      final view = buildFilteredPortfolioView(
        _filterablePortfolio(),
        'aave-v3',
        PortfolioFilter.allWallets,
      );

      expect(view.visibleWalletHoldings, isEmpty);
      expect(view.visibleSuppliedPositions, hasLength(1));
      expect(view.visibleBorrowedPositions, hasLength(1));
      expect(view.selectedProtocolSummary?.protocol, 'aave-v3');
      expect(view.scopeNetValueUsd, '200.00');
      expect(view.totalsSource, PortfolioFilteredTotalsSource.protocolSummary);
    });

    test('wallet filter scopes nested wallet holdings', () {
      final view = buildFilteredPortfolioView(
        _filterablePortfolio(),
        PortfolioFilter.allProtocols,
        '1',
      );

      expect(view.visibleWalletHoldings, hasLength(1));
      final holding = view.visibleWalletHoldings.single;
      expect(holding.wallets, hasLength(1));
      expect(holding.wallets.single.walletId, '1');
      expect(holding.amount, '10.0');
      expect(holding.valueUsd, '10.00');
      expect(holding.priceUsd, '1.00');
      expect(holding.priceStatus, PortfolioPriceStatus.ok);
      expect(view.selectedWalletSummary?.walletId, '1');
      expect(view.scopeNetValueUsd, '100.00');
      expect(view.totalsSource, PortfolioFilteredTotalsSource.walletSummary);
    });

    test('wallet filter hides holdings without matching nested wallet', () {
      final view = buildFilteredPortfolioView(
        _filterablePortfolio(),
        PortfolioFilter.allProtocols,
        'missing',
      );

      expect(view.visibleWalletHoldings, isEmpty);
      expect(view.selectedWalletSummary, isNull);
    });

    test('protocol and wallet filter scopes protocol positions', () {
      final view = buildFilteredPortfolioView(
        _filterablePortfolio(),
        'aave-v3',
        '2',
      );

      expect(view.visibleSuppliedPositions, hasLength(1));
      final supplied = view.visibleSuppliedPositions.single;
      expect(supplied.wallets, hasLength(1));
      expect(supplied.wallets.single.walletId, '2');
      expect(supplied.valueUsd, '80.00');

      expect(view.visibleBorrowedPositions, hasLength(1));
      final borrowed = view.visibleBorrowedPositions.single;
      expect(borrowed.wallets.single.walletId, '2');
      expect(borrowed.valueUsd, '20.00');
      expect(borrowed.valueUsd, isNot(startsWith('-')));
    });

    test('borrowed values remain positive after filtering', () {
      final view = buildFilteredPortfolioView(
        _filterablePortfolio(),
        'aave-v3',
        PortfolioFilter.allWallets,
      );

      for (final position in view.visibleBorrowedPositions) {
        final value = position.valueUsd?.trim();
        expect(value, isNotNull);
        expect(value, isNotEmpty);
        expect(value, isNot(startsWith('-')));
      }
    });

    test('all/all is default filter scope', () {
      final view = buildFilteredPortfolioView(
        _filterablePortfolio(),
        PortfolioFilter.allProtocols,
        PortfolioFilter.allWallets,
      );

      expect(view.visibleSuppliedPositions, hasLength(2));
      expect(view.visibleBorrowedPositions, hasLength(1));
      expect(view.visibleWalletHoldings, hasLength(1));
    });

    test('positions health respects protocol and wallet filters', () {
      final view = buildFilteredPortfolioView(
        _filterablePortfolio(),
        'aave-v3',
        '1',
      );

      expect(view.visiblePositionsHealth, hasLength(1));
      expect(view.visiblePositionsHealth.single.walletId, '1');
      expect(view.visiblePositionsHealth.single.protocol, 'aave-v3');
    });

    test('protocol plus wallet uses wallet summary totals fallback', () {
      final view = buildFilteredPortfolioView(
        _filterablePortfolio(),
        'aave-v3',
        '1',
      );

      expect(view.totalsSource, PortfolioFilteredTotalsSource.walletSummary);
      expect(view.scopeNetValueUsd, '100.00');
      expect(view.selectedProtocolSummary?.protocol, 'aave-v3');
      expect(view.selectedWalletSummary?.walletId, '1');
    });

    test('legacy portfolio without wallets or protocol summaries still filters rows', () {
      final portfolio = Portfolio(
        summary: PortfolioSummary(
          totalValueUsd: '50.00',
          walletsCount: 0,
          assetsCount: 1,
          networksCount: 0,
          updatedAt: '2026-05-19T13:30:00.000Z',
          netValueUsd: '50.00',
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
            balanceRaw: '1000000000000000000',
            decimals: 18,
            priceUsd: '50.00',
            valueUsd: '50.00',
            priceStatus: PortfolioPriceStatus.ok,
          ),
        ],
      );

      final allView = buildFilteredPortfolioView(
        portfolio,
        PortfolioFilter.allProtocols,
        PortfolioFilter.allWallets,
      );
      expect(allView.visibleWalletHoldings, hasLength(1));
      expect(allView.visibleWallets, isEmpty);
      expect(allView.visibleProtocolSummaries, isEmpty);
      expect(allView.scopeNetValueUsd, '50.00');

      final walletScoped = buildFilteredPortfolioView(
        portfolio,
        PortfolioFilter.walletProtocol,
        '1',
      );
      expect(walletScoped.visibleWalletHoldings, isEmpty);
      expect(walletScoped.selectedWalletSummary, isNull);
    });

    test('overview health factor prefers protocol summary for protocol scope', () {
      final view = buildFilteredPortfolioView(
        _filterablePortfolio(),
        'aave-v3',
        PortfolioFilter.allWallets,
      );

      expect(view.overviewHealthFactor, '1.80');
      expect(
        view.overviewHealthFactorSource,
        PortfolioFilteredHealthFactorSource.protocolSummary,
      );
    });

    test('overview health factor uses wallet summary when wallet selected', () {
      final view = buildFilteredPortfolioView(
        _filterablePortfolio(),
        PortfolioFilter.allProtocols,
        '2',
      );

      expect(view.overviewHealthFactor, '2.10');
      expect(
        view.overviewHealthFactorSource,
        PortfolioFilteredHealthFactorSource.walletSummary,
      );
    });
  });
}

Portfolio _filterablePortfolio() {
  return Portfolio(
    summary: PortfolioSummary(
      totalValueUsd: '300.00',
      walletsCount: 2,
      assetsCount: 2,
      networksCount: 1,
      updatedAt: '2026-05-19T13:30:00.000Z',
      netValueUsd: '300.00',
      walletValueUsd: '110.00',
      suppliedValueUsd: '150.00',
      borrowedValueUsd: '40.00',
      grossValueUsd: '260.00',
    ),
    networks: const <PortfolioNetwork>[],
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
      PortfolioWalletSummary(
        walletId: '2',
        walletAddress: '0xwallet2',
        walletLabel: 'Secondary',
        walletValueUsd: '100.00',
        suppliedValueUsd: '80.00',
        borrowedValueUsd: '20.00',
        grossValueUsd: '180.00',
        netValueUsd: '200.00',
        healthFactor: '2.10',
        healthFactorStatus: PortfolioHealthFactorStatus.safe,
        healthFactorStatusLabel: 'Safe',
      ),
    ],
    protocolSummaries: const <PortfolioProtocolSummary>[
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
    walletHoldings: const <PortfolioHolding>[
      PortfolioHolding(
        kind: 'wallet',
        networkId: 1,
        network: 'ethereum',
        networkName: 'Ethereum',
        chainId: 1,
        assetId: '10',
        assetSymbol: 'USDC',
        assetAddress: '0xusdc',
        symbol: 'USDC',
        address: '0xusdc',
        amount: '110.0',
        balanceRaw: '110000000',
        decimals: 6,
        priceUsd: '1.00',
        valueUsd: '110.00',
        priceStatus: PortfolioPriceStatus.ok,
        wallets: <PortfolioWalletBreakdown>[
          PortfolioWalletBreakdown(
            walletId: '1',
            address: '0xwallet1',
            label: 'Main',
            walletAddress: '0xwallet1',
            walletLabel: 'Main',
            amount: '10.0',
            balanceRaw: '10000000',
            balance: '10.0',
            valueUsd: '10.00',
            syncedAt: null,
            blockNumber: null,
          ),
          PortfolioWalletBreakdown(
            walletId: '2',
            address: '0xwallet2',
            label: 'Secondary',
            walletAddress: '0xwallet2',
            walletLabel: 'Secondary',
            amount: '100.0',
            balanceRaw: '100000000',
            balance: '100.0',
            valueUsd: '100.00',
            syncedAt: null,
            blockNumber: null,
          ),
        ],
      ),
    ],
    protocolPositions: PortfolioProtocolPositions(
      supplied: <PortfolioProtocolPosition>[
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
          underlyingAddress: '0xusdc',
          tokenSymbol: 'aUSDC',
          tokenAddress: '0xausdc',
          amount: '150.0',
          balanceRaw: null,
          decimals: 6,
          priceUsd: '1.00',
          valueUsd: '150.00',
          priceStatus: PortfolioPriceStatus.ok,
          wallets: <PortfolioWalletBreakdown>[
            _walletBreakdown(
              walletId: '1',
              amount: '70.0',
              valueUsd: '70.00',
            ),
            _walletBreakdown(
              walletId: '2',
              amount: '80.0',
              valueUsd: '80.00',
            ),
          ],
        ),
        PortfolioProtocolPosition(
          kind: 'protocol',
          protocol: 'compound-v3',
          protocolName: 'Compound V3',
          networkId: 1,
          network: 'ethereum',
          networkName: 'Ethereum',
          chainId: 1,
          positionSide: PortfolioPositionSide.supplied,
          tokenRole: 'collateral',
          debtType: null,
          underlyingSymbol: 'ETH',
          underlyingAddress: '0xeth',
          tokenSymbol: 'cETH',
          tokenAddress: '0xceth',
          amount: '1.0',
          balanceRaw: null,
          decimals: 18,
          priceUsd: '10.00',
          valueUsd: '10.00',
          priceStatus: PortfolioPriceStatus.ok,
        ),
      ],
      borrowed: <PortfolioProtocolPosition>[
        PortfolioProtocolPosition(
          kind: 'protocol',
          protocol: 'aave-v3',
          protocolName: 'Aave V3',
          networkId: 1,
          network: 'ethereum',
          networkName: 'Ethereum',
          chainId: 1,
          positionSide: PortfolioPositionSide.borrowed,
          tokenRole: 'debt',
          debtType: PortfolioDebtType.variable,
          underlyingSymbol: 'USDC',
          underlyingAddress: '0xusdc',
          tokenSymbol: 'variableDebtUSDC',
          tokenAddress: '0xdebt',
          amount: '40.0',
          balanceRaw: null,
          decimals: 6,
          priceUsd: '1.00',
          valueUsd: '40.00',
          priceStatus: PortfolioPriceStatus.ok,
          wallets: <PortfolioWalletBreakdown>[
            _walletBreakdown(
              walletId: '1',
              amount: '20.0',
              valueUsd: '20.00',
            ),
            _walletBreakdown(
              walletId: '2',
              amount: '20.0',
              valueUsd: '20.00',
            ),
          ],
        ),
      ],
    ),
    defiRisk: PortfolioDefiRisk(
      positionsHealth: const <PortfolioPositionHealth>[
        PortfolioPositionHealth(
          protocol: 'aave-v3',
          protocolName: 'Aave V3',
          networkId: 1,
          network: 'ethereum',
          networkName: 'Ethereum',
          walletId: '1',
          walletAddress: '0xwallet1',
          walletLabel: 'Main',
          healthFactor: '1.50',
          status: PortfolioHealthFactorStatus.safe,
          statusLabel: 'Safe',
          threshold: '1.0',
          updatedAt: '2026-05-19T13:30:00.000Z',
          stale: false,
        ),
        PortfolioPositionHealth(
          protocol: 'aave-v3',
          protocolName: 'Aave V3',
          networkId: 1,
          network: 'ethereum',
          networkName: 'Ethereum',
          walletId: '2',
          walletAddress: '0xwallet2',
          walletLabel: 'Secondary',
          healthFactor: '2.10',
          status: PortfolioHealthFactorStatus.safe,
          statusLabel: 'Safe',
          threshold: '1.0',
          updatedAt: '2026-05-19T13:30:00.000Z',
          stale: false,
        ),
      ],
    ),
  );
}

PortfolioWalletBreakdown _walletBreakdown({
  required String walletId,
  required String amount,
  required String valueUsd,
}) {
  return PortfolioWalletBreakdown(
    walletId: walletId,
    address: '0x$walletId',
    label: walletId,
    walletAddress: '0x$walletId',
    walletLabel: walletId,
    amount: amount,
    balanceRaw: '0',
    balance: amount,
    valueUsd: valueUsd,
    syncedAt: null,
    blockNumber: null,
  );
}

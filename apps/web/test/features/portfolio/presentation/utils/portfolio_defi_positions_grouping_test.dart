import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_price_status.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/utils/portfolio_defi_positions_grouping.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('groupDefiPositionsByProtocol', () {
    test('splits nested wallets into separate network wallet groups', () {
      final sections = groupDefiPositionsByProtocol([
        _position(
          wallets: const [
            PortfolioWalletBreakdown(
              walletId: '1',
              address: '0x1',
              label: 'Main',
              walletAddress: '0x1',
              walletLabel: 'Main',
              amount: '10',
              balanceRaw: '0',
              balance: '10',
              valueUsd: '10.00',
              syncedAt: null,
              blockNumber: null,
            ),
            PortfolioWalletBreakdown(
              walletId: '2',
              address: '0x2',
              label: 'Secondary',
              walletAddress: '0x2',
              walletLabel: 'Secondary',
              amount: '20',
              balanceRaw: '0',
              balance: '20',
              valueUsd: '20.00',
              syncedAt: null,
              blockNumber: null,
            ),
          ],
        ),
      ]);

      expect(sections, hasLength(1));
      expect(sections.single.groups, hasLength(2));
      expect(sections.single.groups.first.walletId, '1');
      expect(sections.single.groups.last.walletId, '2');
    });
  });

  group('matchPositionHealth', () {
    test('matches by walletId first', () {
      final health = matchPositionHealth(
        positionsHealth: const [
          PortfolioPositionHealth(
            protocol: 'aave-v3',
            protocolName: 'Aave V3',
            networkId: 1,
            network: 'ethereum',
            networkName: 'Ethereum',
            walletId: '1',
            walletAddress: '0x1',
            walletLabel: 'Main',
            healthFactor: '1.5',
            status: PortfolioHealthFactorStatus.safe,
            statusLabel: 'Safe',
            threshold: '1.0',
            updatedAt: null,
            stale: false,
          ),
        ],
        protocol: 'aave-v3',
        networkId: 1,
        walletId: '1',
        walletAddress: '0xother',
      );

      expect(health?.healthFactor, '1.5');
    });

    test('falls back to walletAddress', () {
      final health = matchPositionHealth(
        positionsHealth: const [
          PortfolioPositionHealth(
            protocol: 'aave-v3',
            protocolName: 'Aave V3',
            networkId: 1,
            network: 'ethereum',
            networkName: 'Ethereum',
            walletId: '1',
            walletAddress: '0xwallet1',
            walletLabel: null,
            healthFactor: '2.0',
            status: PortfolioHealthFactorStatus.atRisk,
            statusLabel: 'At risk',
            threshold: '1.0',
            updatedAt: null,
            stale: false,
          ),
        ],
        protocol: 'aave-v3',
        networkId: 1,
        walletId: '',
        walletAddress: '0xwallet1',
      );

      expect(health?.status, PortfolioHealthFactorStatus.atRisk);
    });
  });

  group('buildGroupHealthFactorDisplay', () {
    test('returns missing display when no match', () {
      final display = buildGroupHealthFactorDisplay(
        positionsHealth: const [],
        group: PortfolioDefiNetworkWalletGroup(
          protocol: 'aave-v3',
          protocolName: 'Aave V3',
          networkId: 1,
          networkName: 'Ethereum',
          walletId: '9',
          walletAddress: '0x9',
          walletLabel: null,
          positions: const [],
        ),
      );

      expect(display.status, PortfolioHealthFactorStatus.missing);
    });
  });
}

PortfolioProtocolPosition _position({
  List<PortfolioWalletBreakdown> wallets = const [],
}) {
  return PortfolioProtocolPosition(
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
    amount: '30',
    balanceRaw: null,
    decimals: 6,
    priceUsd: '1.00',
    valueUsd: '30.00',
    priceStatus: PortfolioPriceStatus.ok,
    wallets: wallets,
  );
}

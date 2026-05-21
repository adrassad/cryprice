import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_price_status.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/utils/portfolio_defi_protocol_grouping.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildPortfolioDefiProtocolGroups', () {
    test('one protocol, one network, one wallet merges supplied and borrowed', () {
      final groups = buildPortfolioDefiProtocolGroups(
        supplied: [
          _position(
            amount: '100',
            valueUsd: '100.00',
            wallets: [_wallet(walletId: 'w1', amount: '100', valueUsd: '100.00')],
          ),
        ],
        borrowed: [
          _position(
            positionSide: PortfolioPositionSide.borrowed,
            debtType: PortfolioDebtType.variable,
            amount: '5',
            valueUsd: '5.00',
            wallets: [_wallet(walletId: 'w1', amount: '5', valueUsd: '5.00')],
          ),
        ],
        positionsHealth: const [],
        selectedProtocol: PortfolioFilter.allProtocols,
        selectedWalletId: PortfolioFilter.allWallets,
      );

      expect(groups, hasLength(1));
      expect(groups.single.protocol, 'aave-v3');
      expect(groups.single.networkWalletGroups, hasLength(1));

      final networkWallet = groups.single.networkWalletGroups.single;
      expect(networkWallet.networkId, 1);
      expect(networkWallet.networkName, 'Ethereum');
      expect(networkWallet.walletId, 'w1');
      expect(networkWallet.supplied, hasLength(1));
      expect(networkWallet.borrowed, hasLength(1));
      expect(networkWallet.supplied.single.amount, '100');
      expect(networkWallet.borrowed.single.amount, '5');
    });

    test('one protocol, multiple networks creates separate groups', () {
      final groups = buildPortfolioDefiProtocolGroups(
        supplied: [
          _position(
            networkId: 1,
            network: 'ethereum',
            networkName: 'Ethereum',
            wallets: [_wallet(walletId: 'w1')],
          ),
          _position(
            networkId: 42161,
            network: 'arbitrum',
            networkName: 'Arbitrum',
            wallets: [_wallet(walletId: 'w1')],
          ),
        ],
        borrowed: const [],
        positionsHealth: const [],
        selectedProtocol: PortfolioFilter.allProtocols,
        selectedWalletId: PortfolioFilter.allWallets,
      );

      expect(groups.single.networkWalletGroups, hasLength(2));
      expect(
        groups.single.networkWalletGroups.map((g) => g.networkName).toList(),
        ['Arbitrum', 'Ethereum'],
      );
    });

    test('one protocol, multiple wallets creates separate groups', () {
      final groups = buildPortfolioDefiProtocolGroups(
        supplied: [
          _position(
            wallets: [
              _wallet(walletId: 'w1', walletLabel: 'Main', amount: '10'),
              _wallet(walletId: 'w2', walletLabel: 'Secondary', amount: '20'),
            ],
          ),
        ],
        borrowed: const [],
        positionsHealth: const [],
        selectedProtocol: PortfolioFilter.allProtocols,
        selectedWalletId: PortfolioFilter.allWallets,
      );

      expect(groups.single.networkWalletGroups, hasLength(2));
      expect(groups.single.networkWalletGroups.first.walletId, 'w1');
      expect(groups.single.networkWalletGroups.last.walletId, 'w2');
    });

    test('selectedProtocol aave-v3 includes only matching protocol', () {
      final groups = buildPortfolioDefiProtocolGroups(
        supplied: [
          _position(protocol: 'aave-v3', protocolName: 'Aave V3'),
          _position(
            protocol: 'compound-v3',
            protocolName: 'Compound V3',
            wallets: [_wallet(walletId: 'w1')],
          ),
        ],
        borrowed: const [],
        positionsHealth: const [],
        selectedProtocol: 'aave-v3',
        selectedWalletId: PortfolioFilter.allWallets,
      );

      expect(groups, hasLength(1));
      expect(groups.single.protocol, 'aave-v3');
    });

    test('selectedProtocol wallet hides all DeFi groups', () {
      final groups = buildPortfolioDefiProtocolGroups(
        supplied: [_position(wallets: [_wallet(walletId: 'w1')])],
        borrowed: const [],
        positionsHealth: const [],
        selectedProtocol: PortfolioFilter.walletProtocol,
        selectedWalletId: PortfolioFilter.allWallets,
      );

      expect(groups, isEmpty);
    });

    test('selectedWalletId filters to matching wallet groups', () {
      final groups = buildPortfolioDefiProtocolGroups(
        supplied: [
          _position(
            wallets: [
              _wallet(walletId: 'w1', amount: '10'),
              _wallet(walletId: 'w2', amount: '20'),
            ],
          ),
        ],
        borrowed: const [],
        positionsHealth: const [],
        selectedProtocol: PortfolioFilter.allProtocols,
        selectedWalletId: 'w2',
      );

      expect(groups.single.networkWalletGroups, hasLength(1));
      expect(groups.single.networkWalletGroups.single.walletId, 'w2');
      expect(groups.single.networkWalletGroups.single.supplied.single.amount, '20');
    });

    test('matches health factor by walletId', () {
      final groups = buildPortfolioDefiProtocolGroups(
        supplied: [_position(wallets: [_wallet(walletId: 'w1')])],
        borrowed: const [],
        positionsHealth: const [
          PortfolioPositionHealth(
            protocol: 'aave-v3',
            protocolName: 'Aave V3',
            networkId: 1,
            network: 'ethereum',
            networkName: 'Ethereum',
            walletId: 'w1',
            walletAddress: '0xabc',
            walletLabel: 'Main',
            healthFactor: '1.61',
            status: PortfolioHealthFactorStatus.atRisk,
            statusLabel: 'At risk',
            threshold: '1.0',
            updatedAt: null,
            stale: false,
          ),
        ],
        selectedProtocol: PortfolioFilter.allProtocols,
        selectedWalletId: PortfolioFilter.allWallets,
      );

      expect(groups.single.networkWalletGroups.single.healthFactor?.healthFactor, '1.61');
      expect(
        groups.single.networkWalletGroups.single.healthFactor?.status,
        PortfolioHealthFactorStatus.atRisk,
      );
    });

    test('matches health factor by walletAddress when walletId missing', () {
      final groups = buildPortfolioDefiProtocolGroups(
        supplied: [
          _position(
            wallets: const [
              PortfolioWalletBreakdown(
                walletId: '',
                address: '0xAbC',
                label: null,
                walletAddress: '0xAbC',
                walletLabel: null,
                amount: '10',
                balanceRaw: '0',
                balance: '10',
                valueUsd: '10.00',
                syncedAt: null,
                blockNumber: null,
              ),
            ],
          ),
        ],
        borrowed: const [],
        positionsHealth: const [
          PortfolioPositionHealth(
            protocol: 'aave-v3',
            protocolName: 'Aave V3',
            networkId: 1,
            network: 'ethereum',
            networkName: 'Ethereum',
            walletId: 'backend-id',
            walletAddress: '0xabc',
            walletLabel: null,
            healthFactor: '2.0',
            status: PortfolioHealthFactorStatus.safe,
            statusLabel: 'Safe',
            threshold: '1.0',
            updatedAt: null,
            stale: false,
          ),
        ],
        selectedProtocol: PortfolioFilter.allProtocols,
        selectedWalletId: PortfolioFilter.allWallets,
      );

      expect(groups.single.networkWalletGroups.single.healthFactor?.healthFactor, '2.0');
    });

    test('missing health factor is null', () {
      final groups = buildPortfolioDefiProtocolGroups(
        supplied: [_position(wallets: [_wallet(walletId: 'w1')])],
        borrowed: const [],
        positionsHealth: const [],
        selectedProtocol: PortfolioFilter.allProtocols,
        selectedWalletId: PortfolioFilter.allWallets,
      );

      expect(groups.single.networkWalletGroups.single.healthFactor, isNull);
    });

    test('borrowed valueUsd stays positive when backend sends negative', () {
      final groups = buildPortfolioDefiProtocolGroups(
        supplied: const [],
        borrowed: [
          _position(
            positionSide: PortfolioPositionSide.borrowed,
            valueUsd: '-2500.00',
            wallets: [_wallet(walletId: 'w1', valueUsd: '-2500.00')],
          ),
        ],
        positionsHealth: const [],
        selectedProtocol: PortfolioFilter.allProtocols,
        selectedWalletId: PortfolioFilter.allWallets,
      );

      expect(groups.single.networkWalletGroups.single.borrowed.single.valueUsd, '2500.00');
    });

    test('preserves priceUsd and priceStatus from parent position', () {
      final groups = buildPortfolioDefiProtocolGroups(
        supplied: [
          _position(
            priceUsd: '3200.50',
            priceStatus: PortfolioPriceStatus.stale,
            wallets: [_wallet(walletId: 'w1')],
          ),
        ],
        borrowed: const [],
        positionsHealth: const [],
        selectedProtocol: PortfolioFilter.allProtocols,
        selectedWalletId: PortfolioFilter.allWallets,
      );

      final row = groups.single.networkWalletGroups.single.supplied.single;
      expect(row.priceUsd, '3200.50');
      expect(row.priceStatus, PortfolioPriceStatus.stale);
    });

    test('uses protocolSummaries order and totals when available', () {
      final groups = buildPortfolioDefiProtocolGroups(
        supplied: [
          _position(
            protocol: 'compound-v3',
            protocolName: 'Compound V3',
            wallets: [_wallet(walletId: 'w1')],
          ),
          _position(wallets: [_wallet(walletId: 'w1')]),
        ],
        borrowed: const [],
        positionsHealth: const [],
        selectedProtocol: PortfolioFilter.allProtocols,
        selectedWalletId: PortfolioFilter.allWallets,
        protocolSummaries: const [
          PortfolioProtocolSummary(
            protocol: 'aave-v3',
            protocolName: 'Aave V3',
            category: 'lending',
            walletValueUsd: null,
            suppliedValueUsd: '100.00',
            borrowedValueUsd: '5.00',
            grossValueUsd: '100.00',
            netValueUsd: '95.00',
            totalValueUsd: '95.00',
            healthFactor: null,
            healthFactorStatus: null,
            healthFactorStatusLabel: null,
          ),
          PortfolioProtocolSummary(
            protocol: 'compound-v3',
            protocolName: 'Compound V3',
            category: 'lending',
            walletValueUsd: null,
            suppliedValueUsd: '50.00',
            borrowedValueUsd: null,
            grossValueUsd: '50.00',
            netValueUsd: '50.00',
            totalValueUsd: '50.00',
            healthFactor: null,
            healthFactorStatus: null,
            healthFactorStatusLabel: null,
          ),
        ],
      );

      expect(groups.map((g) => g.protocol).toList(), ['aave-v3', 'compound-v3']);
      expect(groups.first.category, 'lending');
      expect(groups.first.netValueUsd, '95.00');
      expect(groups.first.suppliedValueUsd, '100.00');
      expect(groups.first.borrowedValueUsd, '5.00');
    });
  });

  group('matchGroupPositionHealth', () {
    test('does not fall back to address when walletId is present but unmatched', () {
      final health = matchGroupPositionHealth(
        positionsHealth: const [
          PortfolioPositionHealth(
            protocol: 'aave-v3',
            protocolName: 'Aave V3',
            networkId: 1,
            network: 'ethereum',
            networkName: 'Ethereum',
            walletId: 'other',
            walletAddress: '0xabc',
            walletLabel: null,
            healthFactor: '9.9',
            status: PortfolioHealthFactorStatus.safe,
            statusLabel: 'Safe',
            threshold: null,
            updatedAt: null,
            stale: false,
          ),
        ],
        protocol: 'aave-v3',
        networkId: 1,
        walletId: 'w1',
        walletAddress: '0xabc',
      );

      expect(health, isNull);
    });
  });
}

PortfolioProtocolPosition _position({
  String protocol = 'aave-v3',
  String protocolName = 'Aave V3',
  int networkId = 1,
  String network = 'ethereum',
  String networkName = 'Ethereum',
  PortfolioPositionSide positionSide = PortfolioPositionSide.supplied,
  PortfolioDebtType? debtType,
  String amount = '100',
  String? valueUsd = '100.00',
  String? priceUsd = '1.00',
  PortfolioPriceStatus priceStatus = PortfolioPriceStatus.ok,
  List<PortfolioWalletBreakdown> wallets = const [],
}) {
  return PortfolioProtocolPosition(
    kind: 'protocol',
    protocol: protocol,
    protocolName: protocolName,
    networkId: networkId,
    network: network,
    networkName: networkName,
    chainId: networkId,
    positionSide: positionSide,
    tokenRole: positionSide == PortfolioPositionSide.borrowed ? 'debt' : 'collateral',
    debtType: debtType,
    underlyingSymbol: 'USDC',
    underlyingAddress: '0xusdc',
    tokenSymbol: 'aUSDC',
    tokenAddress: '0xausdc',
    amount: amount,
    balanceRaw: null,
    decimals: 6,
    priceUsd: priceUsd,
    valueUsd: valueUsd,
    priceStatus: priceStatus,
    wallets: wallets,
  );
}

PortfolioWalletBreakdown _wallet({
  required String walletId,
  String walletAddress = '0xwallet',
  String? walletLabel = 'Main',
  String amount = '100',
  String? valueUsd = '100.00',
}) {
  return PortfolioWalletBreakdown(
    walletId: walletId,
    address: walletAddress,
    label: walletLabel,
    walletAddress: walletAddress,
    walletLabel: walletLabel,
    amount: amount,
    balanceRaw: '0',
    balance: amount,
    valueUsd: valueUsd,
    syncedAt: null,
    blockNumber: null,
  );
}

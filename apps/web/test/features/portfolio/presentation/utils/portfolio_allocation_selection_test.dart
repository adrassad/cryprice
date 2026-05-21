import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_allocation.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/utils/portfolio_allocation_selection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('selectAllocationSeries', () {
    final portfolio = Portfolio(
      summary: const PortfolioSummary(
        totalValueUsd: '1000.00',
        walletsCount: 2,
        assetsCount: 2,
        networksCount: 1,
        updatedAt: '2026-05-19T13:30:00.000Z',
      ),
      networks: const [],
      allocation: PortfolioAllocation(
        assets: [
          _item(key: 'usdc', label: 'USDC', valueUsd: '600.00', percentage: '60'),
        ],
        debts: [
          _item(key: 'debt-usdc', label: 'USDC debt', valueUsd: '100.00', percentage: '100'),
        ],
        protocols: [
          _item(key: 'aave-v3', label: 'Aave V3', valueUsd: '700.00', percentage: '70'),
        ],
        networks: [
          _item(key: 'ethereum', label: 'Ethereum', valueUsd: '900.00', percentage: '90'),
        ],
        wallets: [
          PortfolioWalletAllocation(
            walletId: '4',
            walletAddress: '0xabc',
            walletLabel: 'TW',
            assets: [
              _item(key: 'eth', label: 'ETH', valueUsd: '400.00', percentage: '100'),
            ],
            debts: const [],
            protocols: [
              _item(key: 'aave-v3', label: 'Aave V3', valueUsd: '400.00', percentage: '100'),
            ],
            networks: [
              _item(key: 'ethereum', label: 'Ethereum', valueUsd: '400.00', percentage: '100'),
            ],
          ),
        ],
      ),
    );

    test('all wallets + assets returns global assets', () {
      final series = selectAllocationSeries(
        portfolio: portfolio,
        selectedWalletId: PortfolioFilter.allWallets,
        mode: PortfolioAllocationMode.assets,
      );

      expect(series, hasLength(1));
      expect(series.single.label, 'USDC');
    });

    test('all wallets + debts returns global debts', () {
      final series = selectAllocationSeries(
        portfolio: portfolio,
        selectedWalletId: PortfolioFilter.allWallets,
        mode: PortfolioAllocationMode.debts,
      );

      expect(series, hasLength(1));
      expect(series.single.label, 'USDC debt');
    });

    test('selected wallet + assets returns wallet assets', () {
      final series = selectAllocationSeries(
        portfolio: portfolio,
        selectedWalletId: '4',
        mode: PortfolioAllocationMode.assets,
      );

      expect(series, hasLength(1));
      expect(series.single.label, 'ETH');
    });

    test('selected wallet + debts returns wallet debts', () {
      final series = selectAllocationSeries(
        portfolio: portfolio,
        selectedWalletId: '4',
        mode: PortfolioAllocationMode.debts,
      );

      expect(series, isEmpty);
    });

    test('unknown wallet returns empty list', () {
      final series = selectAllocationSeries(
        portfolio: portfolio,
        selectedWalletId: '999',
        mode: PortfolioAllocationMode.assets,
      );

      expect(series, isEmpty);
    });

    test('missing allocation returns empty list', () {
      final emptyPortfolio = Portfolio(
        summary: portfolio.summary,
        networks: const [],
      );

      final series = selectAllocationSeries(
        portfolio: emptyPortfolio,
        selectedWalletId: PortfolioFilter.allWallets,
        mode: PortfolioAllocationMode.assets,
      );

      expect(series, isEmpty);
    });
  });
}

PortfolioAllocationItem _item({
  required String key,
  required String label,
  required String valueUsd,
  required String percentage,
}) {
  return PortfolioAllocationItem(
    key: key,
    label: label,
    valueUsd: valueUsd,
    percentage: percentage,
  );
}

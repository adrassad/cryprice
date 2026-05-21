import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_allocation.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';

enum PortfolioAllocationMode {
  assets,
  debts,
  protocols,
  networks,
}

/// Returns backend-provided allocation series for the active wallet scope.
///
/// Does not aggregate or recalculate values — only selects the correct array.
List<PortfolioAllocationItem> selectAllocationSeries({
  required Portfolio portfolio,
  required String? selectedWalletId,
  required PortfolioAllocationMode mode,
}) {
  final allocation = portfolio.allocation;
  if (allocation == null) {
    return const <PortfolioAllocationItem>[];
  }

  final walletId = PortfolioFilter.normalizeWalletId(selectedWalletId);
  if (PortfolioFilter.isAllWallets(walletId)) {
    return _globalSeries(allocation, mode);
  }

  for (final wallet in allocation.wallets) {
    if (wallet.walletId == walletId) {
      return _walletSeries(wallet, mode);
    }
  }

  return const <PortfolioAllocationItem>[];
}

List<PortfolioAllocationItem> _globalSeries(
  PortfolioAllocation allocation,
  PortfolioAllocationMode mode,
) {
  return switch (mode) {
    PortfolioAllocationMode.assets => allocation.assets,
    PortfolioAllocationMode.debts => allocation.debts,
    PortfolioAllocationMode.protocols => allocation.protocols,
    PortfolioAllocationMode.networks => allocation.networks,
  };
}

List<PortfolioAllocationItem> _walletSeries(
  PortfolioWalletAllocation wallet,
  PortfolioAllocationMode mode,
) {
  return switch (mode) {
    PortfolioAllocationMode.assets => wallet.assets,
    PortfolioAllocationMode.debts => wallet.debts,
    PortfolioAllocationMode.protocols => wallet.protocols,
    PortfolioAllocationMode.networks => wallet.networks,
  };
}

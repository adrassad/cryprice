import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';

/// Locally filtered portfolio rows and scope-aware summary fields.
///
/// Totals fallback (no financial string math):
/// - [all] + [all]: portfolio [PortfolioSummary] / [PortfolioTotals].
/// - specific protocol + [all]: matching [PortfolioProtocolSummary].
/// - [wallet] + [all]: portfolio summary wallet-oriented fields.
/// - [wallet] + wallet id: [PortfolioWalletSummary] for that wallet.
/// - specific protocol + wallet id: rows are wallet-scoped within the protocol;
///   totals use [PortfolioWalletSummary] when present (wallet-wide, not
///   protocol+wallet combined). Overview HF prefers protocol summary, then
///   lowest finite HF from [visiblePositionsHealth] when needed.
class PortfolioFilteredView {
  const PortfolioFilteredView({
    required this.visibleWalletHoldings,
    required this.visibleSuppliedPositions,
    required this.visibleBorrowedPositions,
    required this.visiblePositionsHealth,
    required this.visibleProtocolSummaries,
    required this.visibleWallets,
    required this.selectedWalletSummary,
    required this.selectedProtocolSummary,
    required this.hasVisibleWalletHoldings,
    required this.hasVisibleDefiPositions,
    required this.scopeNetValueUsd,
    required this.scopeWalletValueUsd,
    required this.scopeSuppliedValueUsd,
    required this.scopeBorrowedValueUsd,
    required this.scopeGrossValueUsd,
    required this.scopeTotalValueUsd,
    required this.overviewHealthFactor,
    required this.overviewHealthFactorStatus,
    required this.overviewHealthFactorStatusLabel,
    required this.overviewHealthFactorStale,
    required this.overviewHealthFactorUpdatedAt,
    required this.totalsSource,
    required this.overviewHealthFactorSource,
  });

  final List<PortfolioHolding> visibleWalletHoldings;
  final List<PortfolioProtocolPosition> visibleSuppliedPositions;
  final List<PortfolioProtocolPosition> visibleBorrowedPositions;
  final List<PortfolioPositionHealth> visiblePositionsHealth;
  final List<PortfolioProtocolSummary> visibleProtocolSummaries;
  final List<PortfolioWalletSummary> visibleWallets;
  final PortfolioWalletSummary? selectedWalletSummary;
  final PortfolioProtocolSummary? selectedProtocolSummary;
  final bool hasVisibleWalletHoldings;
  final bool hasVisibleDefiPositions;

  final String? scopeNetValueUsd;
  final String? scopeWalletValueUsd;
  final String? scopeSuppliedValueUsd;
  final String? scopeBorrowedValueUsd;
  final String? scopeGrossValueUsd;
  final String? scopeTotalValueUsd;
  final String? overviewHealthFactor;
  final PortfolioHealthFactorStatus? overviewHealthFactorStatus;
  final String? overviewHealthFactorStatusLabel;
  final bool overviewHealthFactorStale;
  final String? overviewHealthFactorUpdatedAt;

  /// Describes which backend field supplied scope totals.
  final PortfolioFilteredTotalsSource totalsSource;

  /// Describes which backend field supplied overview HF.
  final PortfolioFilteredHealthFactorSource overviewHealthFactorSource;
}

enum PortfolioFilteredTotalsSource {
  portfolioSummary,
  portfolioTotals,
  protocolSummary,
  walletSummary,
  none,
}

enum PortfolioFilteredHealthFactorSource {
  portfolioSummary,
  protocolSummary,
  walletSummary,
  portfolioDefiRisk,
  lowestVisiblePositionHealth,
  none,
}

PortfolioFilteredView buildFilteredPortfolioView(
  Portfolio portfolio,
  String? selectedProtocol,
  String? selectedWalletId,
) {
  final protocol = PortfolioFilter.normalizeProtocol(selectedProtocol);
  final walletId = PortfolioFilter.normalizeWalletId(selectedWalletId);

  final selectedWalletSummary = _findWalletSummary(portfolio, walletId);
  final selectedProtocolSummary = _findProtocolSummary(portfolio, protocol);

  final visibleWallets = portfolio.wallets;
  final visibleProtocolSummaries = _visibleProtocolSummaries(
    portfolio,
    protocol,
  );

  final visibleWalletHoldings = _filterWalletHoldings(
    portfolio.walletHoldings,
    protocol,
    walletId,
  );
  final visibleSuppliedPositions = _filterProtocolPositions(
    portfolio.protocolPositions.supplied,
    protocol,
    walletId,
  );
  final visibleBorrowedPositions = _filterProtocolPositions(
    portfolio.protocolPositions.borrowed,
    protocol,
    walletId,
  );
  final visiblePositionsHealth = _filterPositionsHealth(
    portfolio.defiRisk.positionsHealth,
    protocol,
    walletId,
  );

  final totals = _resolveScopeTotals(
    portfolio: portfolio,
    protocol: protocol,
    walletId: walletId,
    selectedWalletSummary: selectedWalletSummary,
    selectedProtocolSummary: selectedProtocolSummary,
  );
  final overviewHealthFactor = _resolveOverviewHealthFactor(
    portfolio: portfolio,
    protocol: protocol,
    walletId: walletId,
    selectedWalletSummary: selectedWalletSummary,
    selectedProtocolSummary: selectedProtocolSummary,
    visiblePositionsHealth: visiblePositionsHealth,
  );

  return PortfolioFilteredView(
    visibleWalletHoldings: visibleWalletHoldings,
    visibleSuppliedPositions: visibleSuppliedPositions,
    visibleBorrowedPositions: visibleBorrowedPositions,
    visiblePositionsHealth: visiblePositionsHealth,
    visibleProtocolSummaries: visibleProtocolSummaries,
    visibleWallets: visibleWallets,
    selectedWalletSummary: selectedWalletSummary,
    selectedProtocolSummary: selectedProtocolSummary,
    hasVisibleWalletHoldings: visibleWalletHoldings.isNotEmpty,
    hasVisibleDefiPositions:
        visibleSuppliedPositions.isNotEmpty ||
        visibleBorrowedPositions.isNotEmpty,
    scopeNetValueUsd: totals.netValueUsd,
    scopeWalletValueUsd: totals.walletValueUsd,
    scopeSuppliedValueUsd: totals.suppliedValueUsd,
    scopeBorrowedValueUsd: totals.borrowedValueUsd,
    scopeGrossValueUsd: totals.grossValueUsd,
    scopeTotalValueUsd: totals.totalValueUsd,
    overviewHealthFactor: overviewHealthFactor.value,
    overviewHealthFactorStatus: overviewHealthFactor.status,
    overviewHealthFactorStatusLabel: overviewHealthFactor.statusLabel,
    overviewHealthFactorStale: overviewHealthFactor.stale,
    overviewHealthFactorUpdatedAt: overviewHealthFactor.updatedAt,
    totalsSource: totals.source,
    overviewHealthFactorSource: overviewHealthFactor.source,
  );
}

List<PortfolioProtocolSummary> _visibleProtocolSummaries(
  Portfolio portfolio,
  String protocol,
) {
  if (PortfolioFilter.isWalletProtocol(protocol)) {
    return const <PortfolioProtocolSummary>[];
  }
  if (PortfolioFilter.isAllProtocols(protocol)) {
    return portfolio.protocolSummaries;
  }
  final summary = _findProtocolSummary(portfolio, protocol);
  if (summary == null) {
    return const <PortfolioProtocolSummary>[];
  }
  return <PortfolioProtocolSummary>[summary];
}

List<PortfolioHolding> _filterWalletHoldings(
  List<PortfolioHolding> holdings,
  String protocol,
  String walletId,
) {
  if (!_showsWalletHoldings(protocol)) {
    return const <PortfolioHolding>[];
  }

  final filtered = <PortfolioHolding>[];
  for (final holding in holdings) {
    final scoped = _scopeHoldingByWallet(holding, walletId);
    if (scoped != null) {
      filtered.add(scoped);
    }
  }
  return filtered;
}

List<PortfolioProtocolPosition> _filterProtocolPositions(
  List<PortfolioProtocolPosition> positions,
  String protocol,
  String walletId,
) {
  if (!_showsProtocolPositions(protocol)) {
    return const <PortfolioProtocolPosition>[];
  }

  final filtered = <PortfolioProtocolPosition>[];
  for (final position in positions) {
    if (!_matchesProtocolFilter(position.protocol, protocol)) {
      continue;
    }
    final scoped = _scopeProtocolPositionByWallet(position, walletId);
    if (scoped != null) {
      filtered.add(scoped);
    }
  }
  return filtered;
}

List<PortfolioPositionHealth> _filterPositionsHealth(
  List<PortfolioPositionHealth> positionsHealth,
  String protocol,
  String walletId,
) {
  if (PortfolioFilter.isWalletProtocol(protocol)) {
    return const <PortfolioPositionHealth>[];
  }

  return positionsHealth
      .where(
        (entry) =>
            _matchesProtocolHealthFilter(entry.protocol, protocol) &&
            _matchesWalletFilter(entry.walletId, walletId),
      )
      .toList(growable: false);
}

bool _showsWalletHoldings(String protocol) {
  return PortfolioFilter.isAllProtocols(protocol) ||
      PortfolioFilter.isWalletProtocol(protocol);
}

bool _showsProtocolPositions(String protocol) {
  return PortfolioFilter.isAllProtocols(protocol) ||
      PortfolioFilter.isSpecificProtocol(protocol);
}

bool _matchesProtocolFilter(String positionProtocol, String selectedProtocol) {
  if (PortfolioFilter.isAllProtocols(selectedProtocol)) {
    return true;
  }
  return positionProtocol == selectedProtocol;
}

bool _matchesProtocolHealthFilter(
  String positionProtocol,
  String selectedProtocol,
) {
  if (PortfolioFilter.isAllProtocols(selectedProtocol)) {
    return true;
  }
  return positionProtocol == selectedProtocol;
}

bool _matchesWalletFilter(String rowWalletId, String selectedWalletId) {
  if (PortfolioFilter.isAllWallets(selectedWalletId)) {
    return true;
  }
  return rowWalletId == selectedWalletId;
}

PortfolioHolding? _scopeHoldingByWallet(
  PortfolioHolding holding,
  String walletId,
) {
  if (PortfolioFilter.isAllWallets(walletId)) {
    return holding;
  }

  if (holding.wallets.isEmpty) {
    return null;
  }

  final nested = holding.wallets
      .where((wallet) => wallet.walletId == walletId)
      .toList(growable: false);
  if (nested.isEmpty) {
    return null;
  }

  return _holdingWithNestedWallets(holding, nested);
}

PortfolioProtocolPosition? _scopeProtocolPositionByWallet(
  PortfolioProtocolPosition position,
  String walletId,
) {
  if (PortfolioFilter.isAllWallets(walletId)) {
    return position;
  }

  if (position.wallets.isEmpty) {
    return null;
  }

  final nested = position.wallets
      .where((wallet) => wallet.walletId == walletId)
      .toList(growable: false);
  if (nested.isEmpty) {
    return null;
  }

  return _protocolPositionWithNestedWallets(position, nested);
}

PortfolioHolding _holdingWithNestedWallets(
  PortfolioHolding holding,
  List<PortfolioWalletBreakdown> nested,
) {
  final scopedAmount = _scopedAmountFromNested(nested, holding.amount);
  final scopedValueUsd = _scopedValueUsdFromNested(nested, holding.valueUsd);

  return PortfolioHolding(
    kind: holding.kind,
    networkId: holding.networkId,
    network: holding.network,
    networkName: holding.networkName,
    chainId: holding.chainId,
    assetId: holding.assetId,
    assetSymbol: holding.assetSymbol,
    assetAddress: holding.assetAddress,
    symbol: holding.symbol,
    address: holding.address,
    amount: scopedAmount,
    balanceRaw: holding.balanceRaw,
    decimals: holding.decimals,
    priceUsd: holding.priceUsd,
    valueUsd: scopedValueUsd,
    priceStatus: holding.priceStatus,
    logoUrl: holding.logoUrl,
    wallets: nested,
  );
}

PortfolioProtocolPosition _protocolPositionWithNestedWallets(
  PortfolioProtocolPosition position,
  List<PortfolioWalletBreakdown> nested,
) {
  final scopedAmount = _scopedAmountFromNested(nested, position.amount);
  final scopedValueUsd = _scopedValueUsdFromNested(nested, position.valueUsd);

  return PortfolioProtocolPosition(
    kind: position.kind,
    protocol: position.protocol,
    protocolName: position.protocolName,
    networkId: position.networkId,
    network: position.network,
    networkName: position.networkName,
    chainId: position.chainId,
    positionSide: position.positionSide,
    tokenRole: position.tokenRole,
    debtType: position.debtType,
    underlyingSymbol: position.underlyingSymbol,
    underlyingAddress: position.underlyingAddress,
    tokenSymbol: position.tokenSymbol,
    tokenAddress: position.tokenAddress,
    amount: scopedAmount,
    balanceRaw: position.balanceRaw,
    decimals: position.decimals,
    priceUsd: position.priceUsd,
    valueUsd: scopedValueUsd,
    priceStatus: position.priceStatus,
    logoUrl: position.logoUrl,
    wallets: nested,
  );
}

String? _scopedAmountFromNested(
  List<PortfolioWalletBreakdown> nested,
  String? parentAmount,
) {
  if (nested.length == 1) {
    final nestedAmount = nested.first.amount?.trim();
    if (nestedAmount != null && nestedAmount.isNotEmpty) {
      return nested.first.amount;
    }
    final nestedBalance = nested.first.balance.trim();
    if (nestedBalance.isNotEmpty) {
      return nested.first.balance;
    }
  }
  return parentAmount;
}

String? _scopedValueUsdFromNested(
  List<PortfolioWalletBreakdown> nested,
  String? parentValueUsd,
) {
  if (nested.length == 1) {
    final nestedValue = nested.first.valueUsd?.trim();
    if (nestedValue != null && nestedValue.isNotEmpty) {
      return nested.first.valueUsd;
    }
  }
  return parentValueUsd;
}

PortfolioWalletSummary? _findWalletSummary(
  Portfolio portfolio,
  String walletId,
) {
  if (PortfolioFilter.isAllWallets(walletId)) {
    return null;
  }
  for (final wallet in portfolio.wallets) {
    if (wallet.walletId == walletId) {
      return wallet;
    }
  }
  return null;
}

PortfolioProtocolSummary? _findProtocolSummary(
  Portfolio portfolio,
  String protocol,
) {
  if (!PortfolioFilter.isSpecificProtocol(protocol)) {
    return null;
  }
  for (final summary in portfolio.protocolSummaries) {
    if (summary.protocol == protocol) {
      return summary;
    }
  }
  return null;
}

class _ScopeTotals {
  const _ScopeTotals({
    required this.source,
    this.netValueUsd,
    this.walletValueUsd,
    this.suppliedValueUsd,
    this.borrowedValueUsd,
    this.grossValueUsd,
    this.totalValueUsd,
  });

  final PortfolioFilteredTotalsSource source;
  final String? netValueUsd;
  final String? walletValueUsd;
  final String? suppliedValueUsd;
  final String? borrowedValueUsd;
  final String? grossValueUsd;
  final String? totalValueUsd;
}

_ScopeTotals _resolveScopeTotals({
  required Portfolio portfolio,
  required String protocol,
  required String walletId,
  required PortfolioWalletSummary? selectedWalletSummary,
  required PortfolioProtocolSummary? selectedProtocolSummary,
}) {
  if (PortfolioFilter.isWalletProtocol(protocol)) {
    return _scopeTotalsFromPortfolioWalletFields(portfolio);
  }

  final hasSpecificWallet = !PortfolioFilter.isAllWallets(walletId);
  final hasSpecificProtocol = PortfolioFilter.isSpecificProtocol(protocol);
  final isWalletScope =
      PortfolioFilter.isWalletProtocol(protocol) || hasSpecificWallet;

  if (hasSpecificProtocol && hasSpecificWallet) {
    if (selectedWalletSummary != null) {
      return _scopeTotalsFromWalletSummary(selectedWalletSummary);
    }
    if (selectedProtocolSummary != null) {
      return _scopeTotalsFromProtocolSummary(selectedProtocolSummary);
    }
    return _scopeTotalsFromPortfolio(portfolio);
  }

  if (hasSpecificWallet && selectedWalletSummary != null) {
    return _scopeTotalsFromWalletSummary(selectedWalletSummary);
  }

  if (hasSpecificProtocol && selectedProtocolSummary != null) {
    return _scopeTotalsFromProtocolSummary(selectedProtocolSummary);
  }

  if (isWalletScope) {
    return _scopeTotalsFromPortfolioWalletFields(portfolio);
  }

  return _scopeTotalsFromPortfolio(portfolio);
}

_ScopeTotals _scopeTotalsFromWalletSummary(PortfolioWalletSummary summary) {
  return _ScopeTotals(
    source: PortfolioFilteredTotalsSource.walletSummary,
    netValueUsd: summary.netValueUsd,
    walletValueUsd: summary.walletValueUsd,
    suppliedValueUsd: summary.suppliedValueUsd,
    borrowedValueUsd: summary.borrowedValueUsd,
    grossValueUsd: summary.grossValueUsd,
    totalValueUsd: summary.netValueUsd ?? summary.grossValueUsd,
  );
}

_ScopeTotals _scopeTotalsFromProtocolSummary(
  PortfolioProtocolSummary summary,
) {
  return _ScopeTotals(
    source: PortfolioFilteredTotalsSource.protocolSummary,
    netValueUsd: summary.netValueUsd,
    walletValueUsd: summary.walletValueUsd,
    suppliedValueUsd: summary.suppliedValueUsd,
    borrowedValueUsd: summary.borrowedValueUsd,
    grossValueUsd: summary.grossValueUsd,
    totalValueUsd: summary.totalValueUsd ?? summary.netValueUsd,
  );
}

_ScopeTotals _scopeTotalsFromPortfolioWalletFields(Portfolio portfolio) {
  final summary = portfolio.summary;
  final totals = portfolio.totals;

  if (_hasAnyValue(
    totals.walletValueUsd,
    summary.walletValueUsd,
    totals.netValueUsd,
  )) {
    return _ScopeTotals(
      source: PortfolioFilteredTotalsSource.portfolioTotals,
      netValueUsd: _firstNonBlank([
        totals.netValueUsd,
        summary.netValueUsd,
        summary.totalValueUsd,
      ]),
      walletValueUsd: _firstNonBlank([
        totals.walletValueUsd,
        summary.walletValueUsd,
      ]),
      suppliedValueUsd: _firstNonBlank([
        totals.suppliedValueUsd,
        summary.suppliedValueUsd,
      ]),
      borrowedValueUsd: _firstNonBlank([
        totals.borrowedValueUsd,
        summary.borrowedValueUsd,
      ]),
      grossValueUsd: _firstNonBlank([
        totals.grossValueUsd,
        summary.grossValueUsd,
      ]),
      totalValueUsd: _firstNonBlank([
        totals.netValueUsd,
        totals.grossValueUsd,
        summary.totalValueUsd,
      ]),
    );
  }

  if (_hasAnyValue(
    summary.walletValueUsd,
    summary.netValueUsd,
    summary.grossValueUsd,
  )) {
    return _ScopeTotals(
      source: PortfolioFilteredTotalsSource.portfolioSummary,
      netValueUsd: summary.netValueUsd,
      walletValueUsd: summary.walletValueUsd,
      suppliedValueUsd: summary.suppliedValueUsd,
      borrowedValueUsd: summary.borrowedValueUsd,
      grossValueUsd: summary.grossValueUsd,
      totalValueUsd: summary.totalValueUsd,
    );
  }

  return const _ScopeTotals(source: PortfolioFilteredTotalsSource.none);
}

_ScopeTotals _scopeTotalsFromPortfolio(Portfolio portfolio) {
  final totals = portfolio.totals;
  final summary = portfolio.summary;

  if (_hasAnyValue(
    totals.netValueUsd,
    totals.grossValueUsd,
    totals.walletValueUsd,
  )) {
    return _ScopeTotals(
      source: PortfolioFilteredTotalsSource.portfolioTotals,
      netValueUsd: _firstNonBlank([
        totals.netValueUsd,
        summary.netValueUsd,
        summary.totalValueUsd,
      ]),
      walletValueUsd: _firstNonBlank([
        totals.walletValueUsd,
        summary.walletValueUsd,
      ]),
      suppliedValueUsd: _firstNonBlank([
        totals.suppliedValueUsd,
        summary.suppliedValueUsd,
      ]),
      borrowedValueUsd: _firstNonBlank([
        totals.borrowedValueUsd,
        summary.borrowedValueUsd,
      ]),
      grossValueUsd: _firstNonBlank([
        totals.grossValueUsd,
        summary.grossValueUsd,
      ]),
      totalValueUsd: _firstNonBlank([
        totals.netValueUsd,
        totals.grossValueUsd,
        summary.totalValueUsd,
      ]),
    );
  }

  if (_hasAnyValue(
    summary.netValueUsd,
    summary.totalValueUsd,
    summary.grossValueUsd,
  )) {
    return _ScopeTotals(
      source: PortfolioFilteredTotalsSource.portfolioSummary,
      netValueUsd: summary.netValueUsd ?? summary.totalValueUsd,
      walletValueUsd: summary.walletValueUsd,
      suppliedValueUsd: summary.suppliedValueUsd,
      borrowedValueUsd: summary.borrowedValueUsd,
      grossValueUsd: summary.grossValueUsd,
      totalValueUsd: summary.totalValueUsd,
    );
  }

  return const _ScopeTotals(source: PortfolioFilteredTotalsSource.none);
}

String? _firstNonBlank(List<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return value;
    }
  }
  return null;
}

bool _hasAnyValue(String? first, [String? second, String? third]) {
  for (final value in [first, second, third]) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return true;
    }
  }
  return false;
}

class _OverviewHealthFactor {
  const _OverviewHealthFactor({
    required this.source,
    this.value,
    this.status,
    this.statusLabel,
    this.stale = false,
    this.updatedAt,
  });

  final PortfolioFilteredHealthFactorSource source;
  final String? value;
  final PortfolioHealthFactorStatus? status;
  final String? statusLabel;
  final bool stale;
  final String? updatedAt;
}

_OverviewHealthFactor _resolveOverviewHealthFactor({
  required Portfolio portfolio,
  required String protocol,
  required String walletId,
  required PortfolioWalletSummary? selectedWalletSummary,
  required PortfolioProtocolSummary? selectedProtocolSummary,
  required List<PortfolioPositionHealth> visiblePositionsHealth,
}) {
  if (PortfolioFilter.isWalletProtocol(protocol)) {
    if (!PortfolioFilter.isAllWallets(walletId) &&
        selectedWalletSummary != null) {
      return _overviewFromWalletSummary(selectedWalletSummary);
    }
    return const _OverviewHealthFactor(
      source: PortfolioFilteredHealthFactorSource.none,
      status: PortfolioHealthFactorStatus.none,
    );
  }

  if (PortfolioFilter.isSpecificProtocol(protocol)) {
    if (selectedProtocolSummary != null &&
        _hasScopedHealthFactor(
          value: selectedProtocolSummary.healthFactor,
          status: selectedProtocolSummary.healthFactorStatus,
        )) {
      return _overviewFromProtocolSummary(selectedProtocolSummary);
    }
    if (!PortfolioFilter.isAllWallets(walletId) &&
        selectedWalletSummary != null &&
        _hasScopedHealthFactor(
          value: selectedWalletSummary.healthFactor,
          status: selectedWalletSummary.healthFactorStatus,
        )) {
      return _overviewFromWalletSummary(selectedWalletSummary);
    }
    return _overviewFromVisiblePositionsHealth(visiblePositionsHealth);
  }

  if (!PortfolioFilter.isAllWallets(walletId) &&
      selectedWalletSummary != null &&
      _hasScopedHealthFactor(
        value: selectedWalletSummary.healthFactor,
        status: selectedWalletSummary.healthFactorStatus,
      )) {
    return _overviewFromWalletSummary(selectedWalletSummary);
  }

  final portfolioHealthFactor = portfolio.defiRisk.healthFactor;
  if (portfolioHealthFactor != null &&
      (_hasHealthFactorValue(portfolioHealthFactor.value) ||
          portfolioHealthFactor.status != PortfolioHealthFactorStatus.missing)) {
    return _OverviewHealthFactor(
      source: PortfolioFilteredHealthFactorSource.portfolioDefiRisk,
      value: portfolioHealthFactor.value,
      status: portfolioHealthFactor.status,
      statusLabel: portfolioHealthFactor.statusLabel,
      stale: portfolioHealthFactor.stale,
      updatedAt: portfolioHealthFactor.updatedAt,
    );
  }

  return _overviewFromPortfolioSummary(portfolio);
}

_OverviewHealthFactor _overviewFromWalletSummary(
  PortfolioWalletSummary summary,
) {
  return _OverviewHealthFactor(
    source: PortfolioFilteredHealthFactorSource.walletSummary,
    value: summary.healthFactor,
    status: summary.healthFactorStatus,
    statusLabel: summary.healthFactorStatusLabel,
  );
}

_OverviewHealthFactor _overviewFromProtocolSummary(
  PortfolioProtocolSummary summary,
) {
  return _OverviewHealthFactor(
    source: PortfolioFilteredHealthFactorSource.protocolSummary,
    value: summary.healthFactor,
    status: summary.healthFactorStatus,
    statusLabel: summary.healthFactorStatusLabel,
  );
}

_OverviewHealthFactor _overviewFromPortfolioSummary(Portfolio portfolio) {
  final summary = portfolio.summary;
  final status = summary.healthFactorStatus;
  if (_hasHealthFactorValue(summary.healthFactor) ||
      (status != null && status != PortfolioHealthFactorStatus.missing)) {
    return _OverviewHealthFactor(
      source: PortfolioFilteredHealthFactorSource.portfolioSummary,
      value: summary.healthFactor,
      status: status ?? PortfolioHealthFactorStatus.missing,
      statusLabel: null,
    );
  }

  return const _OverviewHealthFactor(
    source: PortfolioFilteredHealthFactorSource.none,
    status: PortfolioHealthFactorStatus.missing,
  );
}

_OverviewHealthFactor _overviewFromVisiblePositionsHealth(
  List<PortfolioPositionHealth> visiblePositionsHealth,
) {
  final lowest = _lowestFiniteHealthFactorEntry(visiblePositionsHealth);
  if (lowest == null) {
    return const _OverviewHealthFactor(
      source: PortfolioFilteredHealthFactorSource.none,
    );
  }

  return _OverviewHealthFactor(
    source: PortfolioFilteredHealthFactorSource.lowestVisiblePositionHealth,
    value: lowest.healthFactor,
    status: lowest.status,
    statusLabel: lowest.statusLabel,
    stale: lowest.stale,
    updatedAt: lowest.updatedAt,
  );
}

bool _hasHealthFactorValue(String? value) {
  final trimmed = value?.trim();
  return trimmed != null && trimmed.isNotEmpty;
}

bool _hasScopedHealthFactor({
  required String? value,
  required PortfolioHealthFactorStatus? status,
}) {
  if (_hasHealthFactorValue(value)) {
    return true;
  }
  return status != null &&
      status != PortfolioHealthFactorStatus.missing &&
      status != PortfolioHealthFactorStatus.none;
}

PortfolioPositionHealth? _lowestFiniteHealthFactorEntry(
  List<PortfolioPositionHealth> entries,
) {
  PortfolioPositionHealth? lowestEntry;
  double? lowestValue;

  for (final entry in entries) {
    final raw = entry.healthFactor?.trim();
    if (raw == null || raw.isEmpty) {
      continue;
    }

    final parsed = double.tryParse(raw);
    if (parsed == null || !parsed.isFinite || parsed <= 0) {
      continue;
    }

    if (lowestValue == null || parsed < lowestValue) {
      lowestValue = parsed;
      lowestEntry = entry;
    }
  }

  return lowestEntry;
}

import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filtered_view.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_formatters.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_health_factor_display.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';

/// Filter scope driving overview headline and metric visibility.
enum PortfolioOverviewScope {
  allPortfolio,
  walletProtocol,
  specificProtocol,
  walletFilter,
  protocolAndWallet,
}

/// Display-ready overview metrics for [PortfolioSummaryCard].
///
/// Values come from [PortfolioFilteredView] scope fields (backend strings only).
/// Metric visibility follows the active protocol/wallet filter scope.
class PortfolioOverviewDisplay {
  const PortfolioOverviewDisplay({
    required this.scope,
    required this.primaryValueUsd,
    required this.netValueUsd,
    required this.walletValueUsd,
    required this.suppliedValueUsd,
    required this.borrowedValueUsd,
    required this.grossValueUsd,
    required this.showHealthFactor,
    required this.showWalletMetric,
    required this.showSuppliedMetric,
    required this.showBorrowedMetric,
    required this.showGrossMetric,
    required this.scopeHint,
    required this.healthFactor,
  });

  final PortfolioOverviewScope scope;
  final String? primaryValueUsd;
  final String? netValueUsd;
  final String? walletValueUsd;
  final String? suppliedValueUsd;
  final String? borrowedValueUsd;
  final String? grossValueUsd;
  final bool showHealthFactor;
  final bool showWalletMetric;
  final bool showSuppliedMetric;
  final bool showBorrowedMetric;
  final bool showGrossMetric;
  final String? scopeHint;
  final PortfolioHealthFactorDisplay? healthFactor;

  factory PortfolioOverviewDisplay.fromFilters({
    required PortfolioFilteredView filteredView,
    required String selectedProtocol,
    required String selectedWalletId,
    required AppLocalizations loc,
    String? summaryUpdatedAtFallback,
  }) {
    final protocol = PortfolioFilter.normalizeProtocol(selectedProtocol);
    final walletId = PortfolioFilter.normalizeWalletId(selectedWalletId);
    final scope = _resolveScope(protocol: protocol, walletId: walletId);
    final healthFactor = buildOverviewHealthFactorDisplay(
      filteredView,
      summaryUpdatedAtFallback: summaryUpdatedAtFallback,
    );

    final netValueUsd = filteredView.scopeNetValueUsd;
    final walletValueUsd = filteredView.scopeWalletValueUsd;
    final suppliedValueUsd = filteredView.scopeSuppliedValueUsd;
    final borrowedValueUsd = positiveFinancialDisplayValue(
      filteredView.scopeBorrowedValueUsd,
    );
    final grossValueUsd = filteredView.scopeGrossValueUsd;

    final showHealthFactor = scope != PortfolioOverviewScope.walletProtocol &&
        healthFactor != null;
    final showWalletMetric =
        scope != PortfolioOverviewScope.specificProtocol &&
        scope != PortfolioOverviewScope.walletProtocol;
    final showDefiBreakdown = scope != PortfolioOverviewScope.walletProtocol;

    return PortfolioOverviewDisplay(
      scope: scope,
      primaryValueUsd: _primaryValueUsd(
        scope: scope,
        netValueUsd: netValueUsd,
        walletValueUsd: walletValueUsd,
      ),
      netValueUsd: netValueUsd,
      walletValueUsd: walletValueUsd,
      suppliedValueUsd: suppliedValueUsd,
      borrowedValueUsd: borrowedValueUsd,
      grossValueUsd: grossValueUsd,
      showHealthFactor: showHealthFactor,
      showWalletMetric: showWalletMetric,
      showSuppliedMetric: showDefiBreakdown,
      showBorrowedMetric: showDefiBreakdown,
      showGrossMetric: showDefiBreakdown,
      scopeHint: _scopeHint(scope: scope, loc: loc),
      healthFactor: healthFactor,
    );
  }

  String primaryValueLabel(AppLocalizations loc) {
    return switch (scope) {
      PortfolioOverviewScope.walletProtocol => loc.portfolioWalletValue,
      PortfolioOverviewScope.specificProtocol => loc.portfolioNetValue,
      _ => loc.portfolioNetValue,
    };
  }

  static PortfolioOverviewScope _resolveScope({
    required String protocol,
    required String walletId,
  }) {
    if (PortfolioFilter.isWalletProtocol(protocol)) {
      return PortfolioOverviewScope.walletProtocol;
    }
    if (PortfolioFilter.isSpecificProtocol(protocol) &&
        !PortfolioFilter.isAllWallets(walletId)) {
      return PortfolioOverviewScope.protocolAndWallet;
    }
    if (PortfolioFilter.isSpecificProtocol(protocol)) {
      return PortfolioOverviewScope.specificProtocol;
    }
    if (!PortfolioFilter.isAllWallets(walletId)) {
      return PortfolioOverviewScope.walletFilter;
    }
    return PortfolioOverviewScope.allPortfolio;
  }

  static String? _primaryValueUsd({
    required PortfolioOverviewScope scope,
    required String? netValueUsd,
    required String? walletValueUsd,
  }) {
    if (scope == PortfolioOverviewScope.walletProtocol) {
      return _firstNonBlank([walletValueUsd, netValueUsd]);
    }
    return netValueUsd;
  }

  static String? _scopeHint({
    required PortfolioOverviewScope scope,
    required AppLocalizations loc,
  }) {
    return switch (scope) {
      PortfolioOverviewScope.protocolAndWallet =>
        loc.portfolioOverviewScopeProtocolWallet,
      PortfolioOverviewScope.walletFilter =>
        loc.portfolioOverviewScopeWalletFilter,
      _ => null,
    };
  }

  static String? _firstNonBlank(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return value;
      }
    }
    return null;
  }
}

/// Returns null when overview HF is not applicable (e.g. wallet protocol scope).
PortfolioHealthFactorDisplay? buildOverviewHealthFactorDisplay(
  PortfolioFilteredView filteredView, {
  String? summaryUpdatedAtFallback,
}) {
  final status = filteredView.overviewHealthFactorStatus;
  if (status == PortfolioHealthFactorStatus.none) {
    return null;
  }

  return PortfolioHealthFactorDisplay(
    value: filteredView.overviewHealthFactor,
    status: status ?? PortfolioHealthFactorStatus.missing,
    statusLabel: filteredView.overviewHealthFactorStatusLabel,
    stale: filteredView.overviewHealthFactorStale,
    updatedAt: resolveHealthFactorUpdatedAt(
      healthFactorUpdatedAt: filteredView.overviewHealthFactorUpdatedAt,
      summaryUpdatedAtFallback: summaryUpdatedAtFallback,
    ),
  );
}

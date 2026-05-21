import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_formatters.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';

/// One selectable wallet chip in the portfolio wallet selector.
class PortfolioWalletSelectorOption {
  const PortfolioWalletSelectorOption({
    required this.walletId,
    required this.title,
    this.netValueUsd,
  });

  final String walletId;
  final String title;
  final String? netValueUsd;
}

List<PortfolioWalletSelectorOption> buildPortfolioWalletSelectorOptions({
  required Portfolio portfolio,
  required AppLocalizations loc,
}) {
  final entries = portfolio.hasWalletSummaries
      ? _entriesFromWalletSummaries(portfolio.wallets)
      : _entriesDerivedFromPortfolio(portfolio);

  if (entries.isEmpty) {
    return const <PortfolioWalletSelectorOption>[];
  }

  return <PortfolioWalletSelectorOption>[
    PortfolioWalletSelectorOption(
      walletId: PortfolioFilter.allWallets,
      title: loc.portfolioAllWallets,
      netValueUsd: _portfolioAllWalletsNetValue(portfolio),
    ),
    ...entries.map(
      (entry) => PortfolioWalletSelectorOption(
        walletId: entry.walletId,
        title: _walletTitle(entry),
        netValueUsd: entry.netValueUsd,
      ),
    ),
  ];
}

List<_WalletSelectorEntry> _entriesFromWalletSummaries(
  List<PortfolioWalletSummary> wallets,
) {
  return wallets
      .map(
        (wallet) => _WalletSelectorEntry(
          walletId: wallet.walletId,
          walletLabel: wallet.walletLabel,
          walletAddress: wallet.walletAddress,
          netValueUsd: wallet.netValueUsd,
        ),
      )
      .toList(growable: false);
}

List<_WalletSelectorEntry> _entriesDerivedFromPortfolio(Portfolio portfolio) {
  final byWalletId = <String, _WalletSelectorEntry>{};

  void upsert({
    required String walletId,
    String? label,
    String? walletLabel,
    String? address,
    String? walletAddress,
    String? netValueUsd,
  }) {
    if (walletId.trim().isEmpty) {
      return;
    }

    final existing = byWalletId[walletId];
    byWalletId[walletId] = _WalletSelectorEntry(
      walletId: walletId,
      label: _firstNonBlank([existing?.label, label]),
      walletLabel: _firstNonBlank([existing?.walletLabel, walletLabel]),
      address: _firstNonBlank([existing?.address, address]),
      walletAddress: _firstNonBlank([existing?.walletAddress, walletAddress]),
      netValueUsd: _firstNonBlank([existing?.netValueUsd, netValueUsd]),
    );
  }

  for (final holding in portfolio.walletHoldings) {
    for (final wallet in holding.wallets) {
      upsert(
        walletId: wallet.walletId,
        label: wallet.label,
        walletLabel: wallet.walletLabel,
        address: wallet.address,
        walletAddress: wallet.walletAddress,
        netValueUsd: wallet.valueUsd,
      );
    }
  }

  for (final position in portfolio.protocolPositions.supplied) {
    for (final wallet in position.wallets) {
      upsert(
        walletId: wallet.walletId,
        label: wallet.label,
        walletLabel: wallet.walletLabel,
        address: wallet.address,
        walletAddress: wallet.walletAddress,
        netValueUsd: wallet.valueUsd,
      );
    }
  }

  for (final position in portfolio.protocolPositions.borrowed) {
    for (final wallet in position.wallets) {
      upsert(
        walletId: wallet.walletId,
        label: wallet.label,
        walletLabel: wallet.walletLabel,
        address: wallet.address,
        walletAddress: wallet.walletAddress,
        netValueUsd: wallet.valueUsd,
      );
    }
  }

  for (final health in portfolio.defiRisk.positionsHealth) {
    upsert(
      walletId: health.walletId,
      walletLabel: health.walletLabel,
      walletAddress: health.walletAddress,
    );
  }

  final walletIds = byWalletId.keys.toList(growable: false)..sort();
  return walletIds.map((walletId) => byWalletId[walletId]!).toList(growable: false);
}

String? _portfolioAllWalletsNetValue(Portfolio portfolio) {
  final summary = portfolio.summary;
  final totals = portfolio.totals;
  return _firstNonBlank([
    summary.netValueUsd,
    totals.netValueUsd,
    summary.totalValueUsd,
  ]);
}

String _walletTitle(_WalletSelectorEntry entry) {
  final label = _firstNonBlank([entry.walletLabel, entry.label]);
  if (label != null) {
    return label;
  }

  final address = _firstNonBlank([entry.walletAddress, entry.address]);
  if (address != null) {
    return shortenPortfolioAddress(address);
  }

  return entry.walletId;
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

class _WalletSelectorEntry {
  const _WalletSelectorEntry({
    required this.walletId,
    this.label,
    this.walletLabel,
    this.address,
    this.walletAddress,
    this.netValueUsd,
  });

  final String walletId;
  final String? label;
  final String? walletLabel;
  final String? address;
  final String? walletAddress;
  final String? netValueUsd;
}

import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';

/// One selectable protocol card in the portfolio summary strip.
class PortfolioProtocolStripOption {
  const PortfolioProtocolStripOption({
    required this.protocolId,
    required this.title,
    required this.valueUsd,
    this.healthFactorStatus,
    this.healthFactorStatusLabel,
  });

  final String protocolId;
  final String title;
  final String? valueUsd;
  final PortfolioHealthFactorStatus? healthFactorStatus;
  final String? healthFactorStatusLabel;
}

List<PortfolioProtocolStripOption> buildPortfolioProtocolStripOptions({
  required Portfolio portfolio,
  required AppLocalizations loc,
}) {
  if (portfolio.hasProtocolSummaries) {
    return _optionsFromProtocolSummaries(portfolio, loc);
  }
  return _fallbackOptions(portfolio, loc);
}

List<PortfolioProtocolStripOption> _optionsFromProtocolSummaries(
  Portfolio portfolio,
  AppLocalizations loc,
) {
  final summary = portfolio.summary;
  final totals = portfolio.totals;

  return <PortfolioProtocolStripOption>[
    PortfolioProtocolStripOption(
      protocolId: PortfolioFilter.allProtocols,
      title: loc.portfolioAllProtocols,
      valueUsd: _firstNonBlank([
        summary.netValueUsd,
        totals.netValueUsd,
        summary.totalValueUsd,
      ]),
    ),
    PortfolioProtocolStripOption(
      protocolId: PortfolioFilter.walletProtocol,
      title: loc.portfolioWallet,
      valueUsd: _walletStripValueUsd(portfolio),
    ),
    ...portfolio.protocolSummaries
        .where(_isBackendProtocolSummaryForStrip)
        .map(
          (protocolSummary) => PortfolioProtocolStripOption(
            protocolId: protocolSummary.protocol,
            title: protocolSummary.protocolName,
            valueUsd: _firstNonBlank([
              protocolSummary.netValueUsd,
              protocolSummary.totalValueUsd,
            ]),
            healthFactorStatus: protocolSummary.healthFactorStatus,
            healthFactorStatusLabel: protocolSummary.healthFactorStatusLabel,
          ),
        ),
  ];
}

bool _isBackendProtocolSummaryForStrip(PortfolioProtocolSummary summary) {
  final protocolId = summary.protocol.trim();
  return protocolId != PortfolioFilter.walletProtocol &&
      protocolId != PortfolioFilter.allProtocols;
}

List<PortfolioProtocolStripOption> _fallbackOptions(
  Portfolio portfolio,
  AppLocalizations loc,
) {
  final summary = portfolio.summary;
  final totals = portfolio.totals;
  final options = <PortfolioProtocolStripOption>[
    PortfolioProtocolStripOption(
      protocolId: PortfolioFilter.allProtocols,
      title: loc.portfolioAllProtocols,
      valueUsd: _firstNonBlank([
        summary.netValueUsd,
        totals.netValueUsd,
        summary.totalValueUsd,
      ]),
    ),
  ];

  if (portfolio.hasWalletHoldings) {
    options.add(
      PortfolioProtocolStripOption(
        protocolId: PortfolioFilter.walletProtocol,
        title: loc.portfolioWallet,
        valueUsd: _walletStripValueUsd(portfolio),
      ),
    );
  }

  final aavePosition = _firstAaveV3Position(portfolio);
  if (aavePosition != null) {
    options.add(
      PortfolioProtocolStripOption(
        protocolId: aavePosition.protocol,
        title: aavePosition.protocolName,
        valueUsd: null,
      ),
    );
  }

  return options;
}

PortfolioProtocolPosition? _firstAaveV3Position(Portfolio portfolio) {
  for (final position in portfolio.protocolPositions.supplied) {
    if (position.protocol == 'aave-v3') {
      return position;
    }
  }
  for (final position in portfolio.protocolPositions.borrowed) {
    if (position.protocol == 'aave-v3') {
      return position;
    }
  }
  return null;
}

String? _walletStripValueUsd(Portfolio portfolio) {
  final walletSummary = _walletProtocolSummary(portfolio);
  if (walletSummary != null) {
    return _firstNonBlank([
      walletSummary.walletValueUsd,
      walletSummary.netValueUsd,
      walletSummary.totalValueUsd,
    ]);
  }

  final summary = portfolio.summary;
  final totals = portfolio.totals;
  return _firstNonBlank([
    summary.walletValueUsd,
    totals.walletValueUsd,
  ]);
}

PortfolioProtocolSummary? _walletProtocolSummary(Portfolio portfolio) {
  for (final protocolSummary in portfolio.protocolSummaries) {
    if (protocolSummary.protocol == PortfolioFilter.walletProtocol) {
      return protocolSummary;
    }
  }
  return null;
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

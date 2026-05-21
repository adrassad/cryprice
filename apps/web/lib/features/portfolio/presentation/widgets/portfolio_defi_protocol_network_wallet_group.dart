import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/view_models/portfolio_defi_group_models.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_defi_layout.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_defi_position_row.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_formatters.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_group_health_factor_row.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_health_factor_display.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_position_table_header.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PortfolioProtocolNetworkWalletGroupCard extends StatelessWidget {
  const PortfolioProtocolNetworkWalletGroupCard({
    super.key,
    required this.group,
    required this.useTableLayout,
    required this.useStackedGroupHeader,
  });

  final PortfolioDefiNetworkWalletGroupView group;
  final bool useTableLayout;
  final bool useStackedGroupHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final healthFactor = _healthFactorDisplay(group);
    final networkWalletTitle = _networkWalletTitle(group);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            networkWalletTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          PortfolioGroupHealthFactorRow(healthFactor: healthFactor),
          if (group.supplied.isNotEmpty) ...[
            const SizedBox(height: 14),
            PortfolioDefiSideSubsection(
              title: AppLocalizations.of(context)!.portfolioSupplied,
              positions: group.supplied,
              isBorrowed: false,
              useTableLayout: useTableLayout,
            ),
          ],
          if (group.borrowed.isNotEmpty) ...[
            const SizedBox(height: 14),
            PortfolioDefiSideSubsection(
              title: AppLocalizations.of(context)!.portfolioBorrowed,
              subtitle: AppLocalizations.of(context)!.portfolioLiability,
              positions: group.borrowed,
              isBorrowed: true,
              useTableLayout: useTableLayout,
            ),
          ],
        ],
      ),
    );
  }

  PortfolioHealthFactorDisplay _healthFactorDisplay(
    PortfolioDefiNetworkWalletGroupView group,
  ) {
    final matched = group.healthFactor;
    if (matched != null) {
      return PortfolioHealthFactorDisplay.fromPositionHealth(matched);
    }

    return const PortfolioHealthFactorDisplay(
      value: null,
      status: PortfolioHealthFactorStatus.missing,
      statusLabel: null,
      stale: false,
    );
  }

  String _networkWalletTitle(PortfolioDefiNetworkWalletGroupView group) {
    final walletTitle = _walletTitle(group);
    return '${group.networkName} · $walletTitle';
  }

  String _walletTitle(PortfolioDefiNetworkWalletGroupView group) {
    final label = group.walletLabel?.trim();
    if (label != null && label.isNotEmpty) {
      return label;
    }
    final address = group.walletAddress.trim();
    if (address.isNotEmpty) {
      return shortenPortfolioAddress(address);
    }
    return group.walletId.isNotEmpty ? group.walletId : '—';
  }
}

class PortfolioDefiSideSubsection extends StatelessWidget {
  const PortfolioDefiSideSubsection({
    super.key,
    required this.title,
    required this.positions,
    required this.isBorrowed,
    required this.useTableLayout,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<PortfolioProtocolPositionView> positions;
  final bool isBorrowed;
  final bool useTableLayout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: isBorrowed
            ? colorScheme.errorContainer.withValues(alpha: 0.12)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBorrowed
              ? colorScheme.errorContainer.withValues(alpha: 0.45)
              : colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isBorrowed) ...[
                  Icon(
                    Icons.trending_down_rounded,
                    size: 18,
                    color: colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: isBorrowed
                              ? colorScheme.onErrorContainer
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isBorrowed
                                ? colorScheme.onErrorContainer
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isBorrowed)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      loc.portfolioDebt,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (useTableLayout) ...[
            const PortfolioDefiRowDivider(),
            const PortfolioPositionTableHeader(showBackground: true),
            const PortfolioDefiRowDivider(),
            for (var i = 0; i < positions.length; i++) ...[
              isBorrowed
                  ? PortfolioBorrowedPositionRow(
                      position: positions[i],
                      compact: false,
                    )
                  : PortfolioSuppliedPositionRow(
                      position: positions[i],
                      compact: false,
                    ),
              if (i < positions.length - 1) const PortfolioDefiRowDivider(),
            ],
          ] else
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                children: [
                  for (var i = 0; i < positions.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    isBorrowed
                        ? PortfolioBorrowedPositionRow(
                            position: positions[i],
                            compact: true,
                          )
                        : PortfolioSuppliedPositionRow(
                            position: positions[i],
                            compact: true,
                          ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

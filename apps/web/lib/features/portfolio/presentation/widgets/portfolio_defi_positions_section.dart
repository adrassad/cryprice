import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/utils/portfolio_defi_position_display.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/utils/portfolio_defi_protocol_grouping.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/view_models/portfolio_defi_group_models.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_defi_protocol_network_wallet_group.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_formatters.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PortfolioDefiPositionsSection extends StatelessWidget {
  const PortfolioDefiPositionsSection({
    super.key,
    required this.supplied,
    required this.borrowed,
    required this.positionsHealth,
    required this.protocolSummaries,
    required this.selectedProtocol,
    required this.selectedWalletId,
    required this.useTableLayout,
    required this.useStackedGroupHeader,
  });

  final List<PortfolioProtocolPosition> supplied;
  final List<PortfolioProtocolPosition> borrowed;
  final List<PortfolioPositionHealth> positionsHealth;
  final List<PortfolioProtocolSummary> protocolSummaries;
  final String selectedProtocol;
  final String selectedWalletId;
  final bool useTableLayout;
  final bool useStackedGroupHeader;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final groups = buildPortfolioDefiProtocolGroups(
      supplied: supplied,
      borrowed: borrowed,
      positionsHealth: positionsHealth,
      selectedProtocol: selectedProtocol,
      selectedWalletId: selectedWalletId,
      protocolSummaries: protocolSummaries,
    );

    if (groups.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.portfolioDefiPositions,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < groups.length; i++) ...[
              if (i > 0) const SizedBox(height: 20),
              PortfolioDefiProtocolSectionCard(
                group: groups[i],
                useTableLayout: useTableLayout,
                useStackedGroupHeader: useStackedGroupHeader,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PortfolioDefiProtocolSectionCard extends StatelessWidget {
  const PortfolioDefiProtocolSectionCard({
    super.key,
    required this.group,
    required this.useTableLayout,
    required this.useStackedGroupHeader,
  });

  final PortfolioDefiProtocolGroup group;
  final bool useTableLayout;
  final bool useStackedGroupHeader;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryLabel = portfolioProtocolCategoryLabel(loc, group.category);
    final netValue = _protocolNetValue(group);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                group.protocolName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (netValue != null) ...[
              const SizedBox(width: 12),
              Text(
                netValue,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (categoryLabel.isNotEmpty)
                _CategoryChip(label: categoryLabel),
              if (categoryLabel.isNotEmpty) const SizedBox(height: 14),
              for (var i = 0; i < group.networkWalletGroups.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                PortfolioProtocolNetworkWalletGroupCard(
                  group: group.networkWalletGroups[i],
                  useTableLayout: useTableLayout,
                  useStackedGroupHeader: useStackedGroupHeader,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String? _protocolNetValue(PortfolioDefiProtocolGroup group) {
    final value = group.netValueUsd ?? group.totalValueUsd;
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return formatPortfolioUsd(trimmed, unavailableLabel: '');
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

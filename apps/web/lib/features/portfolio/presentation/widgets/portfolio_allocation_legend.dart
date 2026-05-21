import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_allocation.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_formatters.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PortfolioAllocationLegend extends StatelessWidget {
  const PortfolioAllocationLegend({
    super.key,
    required this.items,
    required this.colors,
    this.highlightKey,
  });

  final List<PortfolioAllocationItem> items;
  final List<Color> colors;
  final String? highlightKey;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 8),
            child: _LegendRow(
              item: items[i],
              color: colors[i % colors.length],
              isHighlighted: highlightKey != null && items[i].key == highlightKey,
              unavailableLabel: loc.portfolioValueUnavailable,
            ),
          ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.item,
    required this.color,
    required this.isHighlighted,
    required this.unavailableLabel,
  });

  final PortfolioAllocationItem item;
  final Color color;
  final bool isHighlighted;
  final String unavailableLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final label = _displayLabel(item);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlighted
            ? colorScheme.surfaceContainerHighest
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatPortfolioAllocationPercentage(item.percentage),
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            formatPortfolioUsd(item.valueUsd, unavailableLabel: unavailableLabel),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _displayLabel(PortfolioAllocationItem item) {
    final label = item.label.trim();
    if (label.isNotEmpty) {
      return label;
    }
    final key = item.key.trim();
    if (key.isNotEmpty) {
      return key;
    }
    return '—';
  }
}

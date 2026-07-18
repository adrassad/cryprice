import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_calculate_result.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_position_breakdown.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/utils/health_factor_risk_display.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/widgets/health_factor_warning_list.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class HealthFactorResultCard extends StatelessWidget {
  const HealthFactorResultCard({
    super.key,
    required this.result,
    this.warningsTitle,
  });

  final HealthFactorCalculateResult result;
  final String? warningsTitle;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final riskColors = healthFactorCalcRiskColors(colorScheme, result.riskLevel);
    final unavailable = loc.portfolioValueUnavailable;
    final warningsLabel = warningsTitle ?? loc.hfCalcWarnings;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.hfCalcResult,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: riskColors.$1,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.hfCalcHealthFactor,
                    style: theme.textTheme.labelMedium?.copyWith(color: riskColors.$2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.isInfinite ? '∞' : result.healthFactorDisplay,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: riskColors.$2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${loc.hfCalcRiskLevel}: ${healthFactorCalcRiskLabel(loc, result.riskLevel)}',
                    style: theme.textTheme.bodyMedium?.copyWith(color: riskColors.$2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _TotalRow(
              label: loc.hfCalcCollateralUsd,
              value: healthFactorCalcFormatUsd(result.totals.collateralUsd, unavailable: unavailable),
            ),
            const SizedBox(height: 8),
            _TotalRow(
              label: loc.hfCalcCollateralWeightedUsd,
              value: healthFactorCalcFormatUsd(
                result.totals.collateralWeightedUsd,
                unavailable: unavailable,
              ),
            ),
            const SizedBox(height: 8),
            _TotalRow(
              label: loc.hfCalcBorrowUsd,
              value: healthFactorCalcFormatUsd(result.totals.borrowUsd, unavailable: unavailable),
            ),
            if (result.warnings.isNotEmpty) ...[
              const SizedBox(height: 16),
              HealthFactorWarningList(
                title: warningsLabel,
                warnings: result.warnings,
              ),
            ],
            if (result.positions.supplies.isNotEmpty ||
                result.positions.borrows.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                loc.hfCalcBreakdown,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ..._breakdownSections(
                context,
                title: loc.hfCalcSupplySection,
                rows: result.positions.supplies,
              ),
              ..._breakdownSections(
                context,
                title: loc.hfCalcBorrowSection,
                rows: result.positions.borrows,
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _breakdownSections(
    BuildContext context, {
    required String title,
    required List<HealthFactorPositionBreakdown> rows,
  }) {
    if (rows.isEmpty) {
      return const <Widget>[];
    }
    final theme = Theme.of(context);
    return [
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      ...rows.map(
        (row) => _PositionBreakdownTile(
          key: ValueKey<String>(
            'hf_breakdown_${row.assetId ?? row.symbol ?? row.amount}',
          ),
          row: row,
        ),
      ),
    ];
  }
}

class _PositionBreakdownTile extends StatelessWidget {
  const _PositionBreakdownTile({
    super.key,
    required this.row,
  });

  final HealthFactorPositionBreakdown row;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final unavailable = loc.portfolioValueUnavailable;
    final symbol = row.symbol?.trim();
    final label = symbol != null && symbol.isNotEmpty ? symbol : (row.assetId ?? '—');
    final isCustom = healthFactorCalcIsCustomPriceSource(row.priceSource);
    final marketPrice = row.marketPriceUsd?.trim();
    final usedPrice = row.priceUsd?.trim();
    final valueUsd = row.valueUsd?.trim();
    final amount = row.amount?.trim();

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              _PriceSourceBadge(priceSource: row.priceSource),
            ],
          ),
          if (amount != null && amount.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${loc.hfCalcAmount}: $amount',
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (isCustom && marketPrice != null && marketPrice.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              '${loc.hfCalcMarketPrice}: ${healthFactorCalcFormatUsd(marketPrice, unavailable: unavailable)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (usedPrice != null && usedPrice.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              '${loc.hfCalcUsedPrice}: ${healthFactorCalcFormatUsd(usedPrice, unavailable: unavailable)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (valueUsd != null && valueUsd.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              '${loc.hfCalcPositionValue}: ${healthFactorCalcFormatUsd(valueUsd, unavailable: unavailable)}',
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}

class _PriceSourceBadge extends StatelessWidget {
  const _PriceSourceBadge({required this.priceSource});

  final String? priceSource;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCustom = healthFactorCalcIsCustomPriceSource(priceSource);
    final background = isCustom
        ? colorScheme.tertiaryContainer.withValues(alpha: 0.65)
        : colorScheme.surfaceContainerHighest;
    final foreground = isCustom
        ? colorScheme.onTertiaryContainer
        : colorScheme.onSurfaceVariant;

    return Chip(
      key: Key('hf_price_source_badge_${priceSource ?? 'unknown'}'),
      label: Text(
        healthFactorCalcPriceSourceBadgeLabel(loc, priceSource),
        style: theme.textTheme.labelSmall?.copyWith(color: foreground),
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: background,
      side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

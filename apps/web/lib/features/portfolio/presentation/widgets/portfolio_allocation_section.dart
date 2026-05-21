import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_allocation.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/utils/portfolio_allocation_selection.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_allocation_chart.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_allocation_empty_state.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_allocation_legend.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_allocation_mode_selector.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PortfolioAllocationSection extends StatefulWidget {
  const PortfolioAllocationSection({
    super.key,
    required this.portfolio,
    required this.selectedWalletId,
    this.selectedProtocol,
  });

  final Portfolio portfolio;
  final String selectedWalletId;
  final String? selectedProtocol;

  @override
  State<PortfolioAllocationSection> createState() =>
      _PortfolioAllocationSectionState();
}

class _PortfolioAllocationSectionState extends State<PortfolioAllocationSection> {
  PortfolioAllocationMode _mode = PortfolioAllocationMode.assets;
  String? _highlightKey;

  @override
  void didUpdateWidget(covariant PortfolioAllocationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedWalletId != widget.selectedWalletId) {
      _highlightKey = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.portfolio.hasAllocation) {
      return const SizedBox.shrink();
    }

    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final series = selectAllocationSeries(
      portfolio: widget.portfolio,
      selectedWalletId: widget.selectedWalletId,
      mode: _mode,
    );
    final colors = portfolioAllocationChartColors(colorScheme);
    final highlightKey = _resolveHighlightKey(series);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.portfolioAllocation,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            PortfolioAllocationModeSelector(
              selectedMode: _mode,
              onModeSelected: (mode) {
                setState(() {
                  _mode = mode;
                  _highlightKey = null;
                });
              },
            ),
            const SizedBox(height: 16),
            if (series.isEmpty)
              PortfolioAllocationEmptyState(mode: _mode)
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final useSideBySide = constraints.maxWidth >= 560;
                  final chart = PortfolioAllocationChart(
                    items: series,
                    colors: colors,
                    highlightKey: highlightKey,
                    onHighlightChanged: (key) {
                      setState(() => _highlightKey = key);
                    },
                  );
                  final legend = PortfolioAllocationLegend(
                    items: series,
                    colors: colors,
                    highlightKey: highlightKey,
                  );

                  if (useSideBySide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        chart,
                        const SizedBox(width: 20),
                        Expanded(child: legend),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      Align(child: chart),
                      const SizedBox(height: 16),
                      legend,
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String? _resolveHighlightKey(List<PortfolioAllocationItem> series) {
    if (_highlightKey != null) {
      return _highlightKey;
    }
    return _protocolHighlightKey(series);
  }

  String? _protocolHighlightKey(List<PortfolioAllocationItem> series) {
    if (_mode != PortfolioAllocationMode.protocols) {
      return null;
    }
    final protocol = PortfolioFilter.normalizeProtocol(widget.selectedProtocol);
    if (PortfolioFilter.isAllProtocols(protocol)) {
      return null;
    }
    for (final item in series) {
      final itemProtocol = item.protocol?.trim();
      if (itemProtocol != null && itemProtocol == protocol) {
        return item.key;
      }
      if (item.key == protocol) {
        return item.key;
      }
    }
    return null;
  }
}

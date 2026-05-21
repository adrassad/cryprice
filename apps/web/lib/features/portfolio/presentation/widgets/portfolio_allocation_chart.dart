import 'dart:math' as math;

import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_allocation.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Donut chart driven by backend-provided percentage strings (visual only).
class PortfolioAllocationChart extends StatefulWidget {
  const PortfolioAllocationChart({
    super.key,
    required this.items,
    required this.colors,
    this.highlightKey,
    this.onHighlightChanged,
  });

  final List<PortfolioAllocationItem> items;
  final List<Color> colors;
  final String? highlightKey;
  final ValueChanged<String?>? onHighlightChanged;

  @override
  State<PortfolioAllocationChart> createState() => _PortfolioAllocationChartState();
}

class _PortfolioAllocationChartState extends State<PortfolioAllocationChart> {
  String? _localHighlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final highlightKey = widget.highlightKey ?? _localHighlight;
    final chartItems = _chartEligibleItems(widget.items);
    final slices = _buildSlices(chartItems);

    if (slices.isEmpty) {
      return SizedBox(
        width: 180,
        height: 180,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.surfaceContainerHighest,
          ),
          child: Center(
            child: Icon(
              Icons.pie_chart_outline,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, 220.0);
        return SizedBox(
          width: size,
          height: size,
          child: GestureDetector(
            onTapUp: (details) {
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) {
                return;
              }
              final local = box.globalToLocal(details.globalPosition);
              final index = _hitTestSlice(local, size, slices);
              if (index == null) {
                setState(() => _localHighlight = null);
                widget.onHighlightChanged?.call(null);
                return;
              }
              final key = chartItems[index].key;
              setState(() => _localHighlight = key);
              widget.onHighlightChanged?.call(key);
            },
            child: CustomPaint(
              painter: _DonutChartPainter(
                slices: slices,
                colors: widget.colors,
                highlightKey: highlightKey,
                itemKeys: chartItems.map((item) => item.key).toList(growable: false),
                holeColor: colorScheme.surface,
                strokeColor: colorScheme.surface,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AllocationSlice {
  const _AllocationSlice({required this.weight});

  final double weight;
}

List<_AllocationSlice> _buildSlices(List<PortfolioAllocationItem> items) {
  final slices = <_AllocationSlice>[];
  for (final item in items) {
    final weight = _parsePercentageForChart(item.percentage);
    if (weight == null || weight <= 0) {
      continue;
    }
    slices.add(_AllocationSlice(weight: weight));
  }
  return slices;
}

List<PortfolioAllocationItem> _chartEligibleItems(
  List<PortfolioAllocationItem> items,
) {
  return items
      .where((item) {
        final weight = _parsePercentageForChart(item.percentage);
        return weight != null && weight > 0;
      })
      .toList(growable: false);
}

double? _parsePercentageForChart(String? percentage) {
  final trimmed = percentage?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return double.tryParse(trimmed.replaceAll('%', ''));
}

int? _hitTestSlice(Offset local, double size, List<_AllocationSlice> slices) {
  final center = Offset(size / 2, size / 2);
  final vector = local - center;
  final distance = vector.distance;
  final outerRadius = size / 2;
  final innerRadius = outerRadius * 0.58;
  if (distance < innerRadius || distance > outerRadius) {
    return null;
  }

  var angle = math.atan2(vector.dy, vector.dx);
  if (angle < 0) {
    angle += math.pi * 2;
  }
  angle = (angle + math.pi / 2) % (math.pi * 2);

  final total = slices.fold<double>(0, (sum, slice) => sum + slice.weight);
  if (total <= 0) {
    return null;
  }

  var cursor = 0.0;
  for (var i = 0; i < slices.length; i++) {
    final sweep = (slices[i].weight / total) * math.pi * 2;
    if (angle >= cursor && angle < cursor + sweep) {
      return i;
    }
    cursor += sweep;
  }
  return null;
}

class _DonutChartPainter extends CustomPainter {
  const _DonutChartPainter({
    required this.slices,
    required this.colors,
    required this.highlightKey,
    required this.itemKeys,
    required this.holeColor,
    required this.strokeColor,
  });

  final List<_AllocationSlice> slices;
  final List<Color> colors;
  final String? highlightKey;
  final List<String> itemKeys;
  final Color holeColor;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.58;
    final rect = Rect.fromCircle(center: center, radius: outerRadius);

    final total = slices.fold<double>(0, (sum, slice) => sum + slice.weight);
    if (total <= 0) {
      return;
    }

    var startAngle = -math.pi / 2;
    for (var i = 0; i < slices.length; i++) {
      final sweep = (slices[i].weight / total) * math.pi * 2;
      final isHighlighted =
          highlightKey != null && i < itemKeys.length && itemKeys[i] == highlightKey;
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(
          alpha: isHighlighted ? 1 : (highlightKey == null ? 1 : 0.45),
        )
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, sweep, true, paint);

      final separator = Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawArc(rect, startAngle, sweep, true, separator);

      startAngle += sweep;
    }

    canvas.drawCircle(center, innerRadius, Paint()..color = holeColor);
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.slices != slices ||
        oldDelegate.colors != colors ||
        oldDelegate.highlightKey != highlightKey ||
        oldDelegate.itemKeys != itemKeys;
  }
}

List<Color> portfolioAllocationChartColors(ColorScheme colorScheme) {
  return [
    colorScheme.primary,
    colorScheme.secondary,
    colorScheme.tertiary,
    colorScheme.primaryContainer,
    colorScheme.secondaryContainer,
    colorScheme.tertiaryContainer,
    colorScheme.inversePrimary,
    colorScheme.error,
  ];
}

String portfolioAllocationOtherLabel(AppLocalizations loc) {
  return loc.portfolioAllocationOther;
}

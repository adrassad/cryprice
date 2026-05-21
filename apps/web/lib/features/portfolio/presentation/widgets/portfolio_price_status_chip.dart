import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_price_status.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PortfolioPriceStatusChip extends StatelessWidget {
  const PortfolioPriceStatusChip({
    super.key,
    required this.status,
  });

  final PortfolioPriceStatus status;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final label = switch (status) {
      PortfolioPriceStatus.ok => null,
      PortfolioPriceStatus.missing => loc.portfolioPriceUnavailable,
      PortfolioPriceStatus.stale => loc.portfolioPriceStale,
      PortfolioPriceStatus.unknown => loc.portfolioPriceStatusUnknown,
    };
    if (label == null) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final (background, foreground, icon) = switch (status) {
      PortfolioPriceStatus.missing => (
          colorScheme.errorContainer,
          colorScheme.onErrorContainer,
          Icons.info_outline,
        ),
      PortfolioPriceStatus.stale => (
          colorScheme.tertiaryContainer,
          colorScheme.onTertiaryContainer,
          Icons.schedule_outlined,
        ),
      PortfolioPriceStatus.unknown => (
          colorScheme.secondaryContainer,
          colorScheme.onSecondaryContainer,
          Icons.help_outline,
        ),
      PortfolioPriceStatus.ok => (
          colorScheme.primaryContainer,
          colorScheme.onPrimaryContainer,
          Icons.check_circle_outline,
        ),
    };

    return Chip(
      avatar: Icon(icon, size: 16, color: foreground),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      backgroundColor: background,
      labelStyle: TextStyle(
        color: foreground,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide.none,
    );
  }
}

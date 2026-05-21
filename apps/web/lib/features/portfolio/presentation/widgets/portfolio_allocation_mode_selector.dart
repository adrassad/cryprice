import 'package:cryprice_frontend/features/portfolio/presentation/utils/portfolio_allocation_selection.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PortfolioAllocationModeSelector extends StatelessWidget {
  const PortfolioAllocationModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeSelected,
  });

  final PortfolioAllocationMode selectedMode;
  final ValueChanged<PortfolioAllocationMode> onModeSelected;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final modes = <(PortfolioAllocationMode, String)>[
      (PortfolioAllocationMode.assets, loc.portfolioAllocationAssets),
      (PortfolioAllocationMode.debts, loc.portfolioAllocationDebts),
      (PortfolioAllocationMode.protocols, loc.portfolioAllocationProtocols),
      (PortfolioAllocationMode.networks, loc.portfolioAllocationNetworks),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final entry in modes)
          _ModeChip(
            label: entry.$2,
            isSelected: selectedMode == entry.$1,
            onTap: () => onModeSelected(entry.$1),
            selectedColor: colorScheme.primaryContainer,
            selectedBorder: colorScheme.primary,
            idleColor: colorScheme.surfaceContainerHighest,
            idleBorder: colorScheme.outlineVariant.withValues(alpha: 0.7),
            textColor: selectedMode == entry.$1
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface,
          ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.selectedBorder,
    required this.idleColor,
    required this.idleBorder,
    required this.textColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color selectedBorder;
  final Color idleColor;
  final Color idleBorder;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor.withValues(alpha: 0.45) : idleColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? selectedBorder : idleBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

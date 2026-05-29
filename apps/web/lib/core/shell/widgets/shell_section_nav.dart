import 'package:cryprice_frontend/core/navigation/app_section.dart';
import 'package:cryprice_frontend/core/shell/widgets/shell_alerts_nav_icon.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Section switcher for the dashboard shell (parent supplies selection state).
class ShellSectionNav extends StatelessWidget {
  const ShellSectionNav({
    super.key,
    required this.selectedSection,
    required this.onSectionSelected,
    this.compactLabels = false,
  });

  final AppSection selectedSection;
  final ValueChanged<AppSection> onSectionSelected;
  final bool compactLabels;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final items = <Widget>[
      _ShellSectionNavItem(
        label: loc.navPriceCalculator,
        icon: Icons.calculate_outlined,
        compact: compactLabels,
        selected: selectedSection == AppSection.priceCalculator,
        onTap: () => onSectionSelected(AppSection.priceCalculator),
      ),
      _ShellSectionNavItem(
        label: loc.navPortfolio,
        icon: Icons.pie_chart_outline,
        compact: compactLabels,
        selected: selectedSection == AppSection.portfolio,
        onTap: () => onSectionSelected(AppSection.portfolio),
      ),
      _ShellSectionNavItem(
        label: loc.navAlerts,
        compact: compactLabels,
        selected: selectedSection == AppSection.alerts,
        onTap: () => onSectionSelected(AppSection.alerts),
        iconWidgetBuilder: (Color foreground, bool selected) {
          return ShellAlertsNavIcon(
            size: compactLabels ? 18 : 20,
            color: foreground,
            selected: selected,
          );
        },
      ),
      _ShellSectionNavItem(
        label: loc.navHealthFactorCalculator,
        icon: Icons.monitor_heart_outlined,
        compact: compactLabels,
        selected: selectedSection == AppSection.healthFactorCalculator,
        onTap: () => onSectionSelected(AppSection.healthFactorCalculator),
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          items[i],
        ],
      ],
    );
  }
}

class _ShellSectionNavItem extends StatelessWidget {
  const _ShellSectionNavItem({
    required this.label,
    required this.compact,
    required this.selected,
    required this.onTap,
    this.icon,
    this.iconWidgetBuilder,
  }) : assert(icon != null || iconWidgetBuilder != null);

  final String label;
  final IconData? icon;
  final Widget Function(Color foreground, bool selected)? iconWidgetBuilder;
  final bool compact;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final Color background = selected
        ? colors.primaryContainer
        : colors.surfaceContainerHighest;
    final Color foreground = selected
        ? colors.onPrimaryContainer
        : colors.onSurface;

    final Widget button = Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: compact ? 8 : 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconWidgetBuilder != null)
                iconWidgetBuilder!(foreground, selected)
              else
                Icon(icon, size: compact ? 18 : 20, color: foreground),
              if (!compact) ...[
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: foreground,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (compact) {
      return Tooltip(message: label, child: button);
    }
    return button;
  }
}

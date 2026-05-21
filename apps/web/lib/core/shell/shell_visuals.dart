import 'package:flutter/material.dart';

/// Shared layout tokens and panel styling for shell and auth screens.
abstract final class ShellVisuals {
  static const double wideLayoutMinWidth = 720;
  static const double authCardMaxWidth = 440;
  static const double sectionNavMaxWidth = 300;
  static const double sectionNavReserveWidth = 320;
  static const double sectionNavReserveBottom = 132;

  static const Color brandSeed = Color(0xFF7E57C2);

  static BoxDecoration panelDecoration(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: colors.surfaceContainerHigh.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: colors.primary.withValues(alpha: 0.28),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: colors.primary.withValues(alpha: 0.14),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static Widget panel({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(12),
  }) {
    return DecoratedBox(
      decoration: panelDecoration(context),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

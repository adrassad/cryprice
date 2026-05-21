import 'package:cryprice_frontend/core/shell/shell_visuals.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// CryPrice Material 3 themes (purple-forward dashboard identity).
abstract final class CrypriceTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: ShellVisuals.brandSeed,
      brightness: brightness,
    );

    final TextTheme textTheme = GoogleFonts.montserratTextTheme(
      ThemeData(brightness: brightness).textTheme,
    );

    return ThemeData(
      colorScheme: colorScheme,
      textTheme: textTheme,
      useMaterial3: true,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        backgroundColor: colorScheme.surfaceContainerHigh,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final bool selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color:
                selected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
          );
        }),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.2)),
        ),
      ),
    );
  }
}

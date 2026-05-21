import 'package:cryprice_frontend/core/cubit/locale_cubit.dart';
import 'package:cryprice_frontend/features/theme/cubit/theme_cubit.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Layout for theme/locale command controls.
enum ShellCommandMenuLayout { vertical, horizontal }

/// Left command rail: theme and locale toggles via existing cubits.
class ShellLeftCommandMenu extends StatelessWidget {
  const ShellLeftCommandMenu({
    super.key,
    this.layout = ShellCommandMenuLayout.vertical,
  });

  final ShellCommandMenuLayout layout;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final List<Widget> controls = <Widget>[
      BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (BuildContext context, ThemeMode mode) {
          final bool isDark = mode == ThemeMode.dark;
          return _ShellCommandToggleButton(
            label: isDark ? loc.themeDark : loc.themeLight,
            icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            tooltip: loc.switchTheme,
            compact: layout == ShellCommandMenuLayout.horizontal,
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          );
        },
      ),
      BlocBuilder<LocaleCubit, Locale>(
        builder: (BuildContext context, Locale locale) {
          final bool isRu = locale.languageCode == 'ru';
          return _ShellCommandToggleButton(
            label: isRu ? loc.localeRu : loc.localeEn,
            icon: Icons.language,
            tooltip: loc.switchLanguage,
            compact: layout == ShellCommandMenuLayout.horizontal,
            onPressed: () => context.read<LocaleCubit>().toggleLocale(),
          );
        },
      ),
    ];

    if (layout == ShellCommandMenuLayout.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < controls.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            controls[i],
          ],
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [controls[0], const SizedBox(height: 8), controls[1]],
    );
  }
}

class _ShellCommandToggleButton extends StatelessWidget {
  const _ShellCommandToggleButton({
    required this.label,
    required this.icon,
    required this.tooltip,
    required this.compact,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final String tooltip;
  final bool compact;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 10,
              vertical: compact ? 8 : 10,
            ),
            child:
                compact
                    ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 20,
                          color: theme.colorScheme.onSurface,
                        ),
                        const SizedBox(width: 6),
                        // Text(
                        //   label,
                        //   style: GoogleFonts.montserrat(
                        //     fontSize: 11,
                        //     fontWeight: FontWeight.w600,
                        //     color: theme.colorScheme.onSurface,
                        //   ),
                        // ),
                      ],
                    )
                    : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 22,
                          color: theme.colorScheme.onSurface,
                        ),
                        const SizedBox(height: 4),
                        // Text(
                        //   label,
                        //   style: GoogleFonts.montserrat(
                        //     fontSize: 11,
                        //     fontWeight: FontWeight.w600,
                        //     color: theme.colorScheme.onSurface,
                        //   ),
                        // ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}

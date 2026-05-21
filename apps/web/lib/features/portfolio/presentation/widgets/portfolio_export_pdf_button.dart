import 'package:cryprice_frontend/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Page-level control to download the server-generated portfolio PDF report.
class PortfolioExportPdfButton extends StatelessWidget {
  const PortfolioExportPdfButton({
    super.key,
    required this.isExporting,
    this.compact = false,
  });

  final bool isExporting;
  final bool compact;

  static const Key buttonKey = Key('portfolio-export-pdf');

  static const double _minTapSize = 44;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onExport = isExporting ? null : context.read<PortfolioCubit>().exportPdf;

    final label = isExporting
        ? loc.portfolioExportPdfPreparing
        : compact
            ? loc.portfolioExportPdfShort
            : loc.portfolioExportPdf;

    final foreground = colorScheme.onSecondaryContainer;
    final background = colorScheme.secondaryContainer;

    final style = FilledButton.styleFrom(
      minimumSize: const Size(_minTapSize, _minTapSize),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 18,
        vertical: 12,
      ),
      foregroundColor: foreground,
      backgroundColor: background,
      disabledForegroundColor: foreground.withValues(alpha: 0.72),
      disabledBackgroundColor: background.withValues(alpha: 0.82),
      iconColor: foreground,
      disabledIconColor: foreground.withValues(alpha: 0.72),
    );

    final icon = isExporting
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: foreground,
            ),
          )
        : Icon(
            Icons.download_rounded,
            size: 20,
            color: foreground,
          );

    final button = Semantics(
      button: true,
      label: isExporting ? loc.portfolioExportPdfPreparing : loc.portfolioExportPdf,
      enabled: !isExporting,
      child: FilledButton.tonalIcon(
        key: buttonKey,
        onPressed: onExport,
        style: style,
        icon: icon,
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    if (compact) {
      return Tooltip(
        message: isExporting ? loc.portfolioExportPdfPreparing : loc.portfolioExportPdf,
        child: button,
      );
    }

    return button;
  }
}

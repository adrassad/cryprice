import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_defi_layout.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

const double kPortfolioPositionTableBreakpoint = 600;

class PortfolioPositionTableHeader extends StatelessWidget {
  const PortfolioPositionTableHeader({
    super.key,
    this.showBackground = false,
  });

  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w700,
    );

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PortfolioDefiTableLayout.horizontalPadding,
        vertical: 8,
      ),
      child: Row(
        children: [
          Expanded(
            flex: PortfolioDefiTableLayout.assetFlex,
            child: Text(loc.portfolioAssets, style: headerStyle),
          ),
          Expanded(
            flex: PortfolioDefiTableLayout.balanceFlex,
            child: Text(
              loc.portfolioTokenBalance,
              style: headerStyle,
              textAlign: TextAlign.end,
            ),
          ),
          Expanded(
            flex: PortfolioDefiTableLayout.priceFlex,
            child: Text(
              loc.portfolioCurrentPrice,
              style: headerStyle,
              textAlign: TextAlign.end,
            ),
          ),
          Expanded(
            flex: PortfolioDefiTableLayout.valueFlex,
            child: Text(
              loc.portfolioUsdValue,
              style: headerStyle,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );

    if (!showBackground) {
      return content;
    }

    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      child: content,
    );
  }
}

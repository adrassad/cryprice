import 'package:cryprice_frontend/core/widgets/token_icon.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_price_status.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/utils/portfolio_defi_position_display.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/view_models/portfolio_defi_group_models.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_defi_layout.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_formatters.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_position_price_value_row.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PortfolioSuppliedPositionRow extends StatelessWidget {
  const PortfolioSuppliedPositionRow({
    super.key,
    required this.position,
    required this.compact,
  });

  final PortfolioProtocolPositionView position;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return PortfolioDefiPositionRow(
      position: position,
      compact: compact,
      isBorrowed: false,
    );
  }
}

class PortfolioBorrowedPositionRow extends StatelessWidget {
  const PortfolioBorrowedPositionRow({
    super.key,
    required this.position,
    required this.compact,
  });

  final PortfolioProtocolPositionView position;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return PortfolioDefiPositionRow(
      position: position,
      compact: compact,
      isBorrowed: true,
    );
  }
}

class PortfolioDefiPositionRow extends StatelessWidget {
  const PortfolioDefiPositionRow({
    super.key,
    required this.position,
    required this.compact,
    required this.isBorrowed,
  });

  final PortfolioProtocolPositionView position;
  final bool compact;
  final bool isBorrowed;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final symbol = portfolioDefiPositionViewSymbol(position);
    final tokenSymbol = portfolioDefiPositionViewTokenSymbol(position);
    final balance = formatPortfolioDefiPositionViewBalance(
      position,
      unavailableLabel: loc.portfolioValueUnavailable,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: PortfolioDefiTableLayout.horizontalPadding,
        vertical: compact ? 12 : PortfolioDefiTableLayout.rowVerticalPadding,
      ),
      decoration: compact
          ? BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isBorrowed
                    ? theme.colorScheme.errorContainer.withValues(alpha: 0.45)
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
              ),
            )
          : null,
      child: compact
          ? _MobileDefiPositionLayout(
              symbol: symbol,
              tokenSymbol: tokenSymbol,
              balance: balance,
              position: position,
              isBorrowed: isBorrowed,
              loc: loc,
              theme: theme,
            )
          : _DesktopDefiPositionLayout(
              symbol: symbol,
              tokenSymbol: tokenSymbol,
              balance: balance,
              position: position,
              isBorrowed: isBorrowed,
              loc: loc,
              theme: theme,
            ),
    );
  }
}

class _AssetTitleColumn extends StatelessWidget {
  const _AssetTitleColumn({
    required this.symbol,
    required this.tokenSymbol,
    required this.isBorrowed,
    required this.position,
    required this.loc,
    required this.theme,
    required this.dense,
  });

  final String symbol;
  final String? tokenSymbol;
  final bool isBorrowed;
  final PortfolioProtocolPositionView position;
  final AppLocalizations loc;
  final ThemeData theme;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TokenIcon(
          logoUrl: position.logoUrl,
          symbol: symbol,
          size: PortfolioDefiTableLayout.assetIconSize,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Tooltip(
                message: symbol,
                child: Text(
                  symbol,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: (dense
                          ? theme.textTheme.titleSmall
                          : theme.textTheme.bodyMedium)
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (tokenSymbol != null) ...[
                const SizedBox(height: 2),
                Tooltip(
                  message: tokenSymbol!,
                  child: Text(
                    tokenSymbol!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
              if (isBorrowed) ...[
                const SizedBox(height: 4),
                _BorrowedChips(position: position, loc: loc),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MobileDefiPositionLayout extends StatelessWidget {
  const _MobileDefiPositionLayout({
    required this.symbol,
    required this.tokenSymbol,
    required this.balance,
    required this.position,
    required this.isBorrowed,
    required this.loc,
    required this.theme,
  });

  final String symbol;
  final String? tokenSymbol;
  final String balance;
  final PortfolioProtocolPositionView position;
  final bool isBorrowed;
  final AppLocalizations loc;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AssetTitleColumn(
          symbol: symbol,
          tokenSymbol: tokenSymbol,
          isBorrowed: isBorrowed,
          position: position,
          loc: loc,
          theme: theme,
          dense: true,
        ),
        const SizedBox(height: 10),
        _LabeledValue(label: loc.portfolioTokenBalance, value: balance),
        const SizedBox(height: 8),
        PortfolioDefiPositionPriceValueRow(
          priceUsd: position.priceUsd,
          priceStatus: position.priceStatus,
          valueUsd: position.valueUsd,
          isBorrowed: isBorrowed,
        ),
      ],
    );
  }
}

class _DesktopDefiPositionLayout extends StatelessWidget {
  const _DesktopDefiPositionLayout({
    required this.symbol,
    required this.tokenSymbol,
    required this.balance,
    required this.position,
    required this.isBorrowed,
    required this.loc,
    required this.theme,
  });

  final String symbol;
  final String? tokenSymbol;
  final String balance;
  final PortfolioProtocolPositionView position;
  final bool isBorrowed;
  final AppLocalizations loc;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: PortfolioDefiTableLayout.assetFlex,
          child: _AssetTitleColumn(
            symbol: symbol,
            tokenSymbol: tokenSymbol,
            isBorrowed: isBorrowed,
            position: position,
            loc: loc,
            theme: theme,
            dense: false,
          ),
        ),
        Expanded(
          flex: PortfolioDefiTableLayout.balanceFlex,
          child: _AlignedCellText(value: balance),
        ),
        Expanded(
          flex: PortfolioDefiTableLayout.priceFlex,
          child: Align(
            alignment: Alignment.centerRight,
            child: PortfolioPositionPriceCell(
              priceUsd: position.priceUsd,
              priceStatus: position.priceStatus,
              compact: true,
            ),
          ),
        ),
        Expanded(
          flex: PortfolioDefiTableLayout.valueFlex,
          child: Align(
            alignment: Alignment.centerRight,
            child: PortfolioDefiPositionValueCell(
              valueUsd: position.valueUsd,
              priceStatus: position.priceStatus,
              isBorrowed: isBorrowed,
            ),
          ),
        ),
      ],
    );
  }
}

class _AlignedCellText extends StatelessWidget {
  const _AlignedCellText({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.end,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class PortfolioDefiPositionPriceValueRow extends StatelessWidget {
  const PortfolioDefiPositionPriceValueRow({
    super.key,
    required this.priceUsd,
    required this.priceStatus,
    required this.valueUsd,
    required this.isBorrowed,
  });

  final String? priceUsd;
  final PortfolioPriceStatus priceStatus;
  final String? valueUsd;
  final bool isBorrowed;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PortfolioPositionPriceCell(
          priceUsd: priceUsd,
          priceStatus: priceStatus,
          label: loc.portfolioCurrentPrice,
        ),
        const SizedBox(height: 8),
        PortfolioDefiPositionValueCell(
          valueUsd: valueUsd,
          priceStatus: priceStatus,
          isBorrowed: isBorrowed,
          label: loc.portfolioUsdValue,
        ),
      ],
    );
  }
}

class PortfolioDefiPositionValueCell extends StatelessWidget {
  const PortfolioDefiPositionValueCell({
    super.key,
    required this.valueUsd,
    required this.priceStatus,
    required this.isBorrowed,
    this.label,
  });

  final String? valueUsd;
  final PortfolioPriceStatus priceStatus;
  final bool isBorrowed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final valueText = formatPortfolioPositionValueUsd(
      valueUsd: valueUsd,
      priceStatus: priceStatus,
      unavailableLabel: loc.portfolioValueUnavailable,
      ensurePositive: isBorrowed,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Text(
            label!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        if (label != null) const SizedBox(height: 2),
        Text(
          valueText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _BorrowedChips extends StatelessWidget {
  const _BorrowedChips({
    required this.position,
    required this.loc,
  });

  final PortfolioProtocolPositionView position;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (position.debtType == null) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        _MiniChip(
          label: _debtTypeLabel(loc, position.debtType!),
          background: colorScheme.errorContainer,
          foreground: colorScheme.onErrorContainer,
        ),
      ],
    );
  }

  String _debtTypeLabel(AppLocalizations loc, PortfolioDebtType debtType) {
    return switch (debtType) {
      PortfolioDebtType.stable => loc.portfolioStableDebt,
      PortfolioDebtType.variable => loc.portfolioVariableDebt,
      PortfolioDebtType.unknown => loc.portfolioUnknown,
    };
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LabeledValue extends StatelessWidget {
  const _LabeledValue({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

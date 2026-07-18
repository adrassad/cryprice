import 'package:cryprice_frontend/core/widgets/token_icon.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/utils/portfolio_holding_display.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_defi_layout.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_formatters.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_position_price_value_row.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Wallet holdings block for the portfolio tab.
///
/// For lazy icon loading inside the portfolio [CustomScrollView], use
/// [buildScrollSlivers] instead of embedding this widget in a [Column].
class PortfolioWalletHoldingsSection extends StatelessWidget {
  const PortfolioWalletHoldingsSection({
    super.key,
    required this.holdings,
    required this.useTableLayout,
  });

  final List<PortfolioHolding> holdings;
  final bool useTableLayout;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PortfolioWalletHoldingsTitle(useTableLayout: useTableLayout),
            const SizedBox(height: 14),
            if (useTableLayout)
              _WalletHoldingsTableBody(holdings: holdings)
            else
              _WalletHoldingsMobileBody(holdings: holdings),
          ],
        ),
      ),
    );
  }

  /// Lazily built slivers for [CustomScrollView] (only visible rows mount).
  static List<Widget> buildScrollSlivers({
    required BuildContext context,
    required List<PortfolioHolding> holdings,
    required bool useTableLayout,
  }) {
    if (holdings.isEmpty) {
      return const <Widget>[];
    }

    final theme = Theme.of(context);
    final cardColor = theme.cardColor;

    return <Widget>[
      SliverToBoxAdapter(
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PortfolioWalletHoldingsTitle(useTableLayout: useTableLayout),
                const SizedBox(height: 14),
                if (useTableLayout) const _WalletHoldingsTableHeader(),
              ],
            ),
          ),
        ),
      ),
      SliverList.builder(
        itemCount: holdings.length,
        itemBuilder: (BuildContext context, int index) {
          return Material(
            color: cardColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (useTableLayout && index > 0)
                  const Divider(height: 1, indent: 16, endIndent: 16),
                PortfolioWalletHoldingRow(
                  holding: holdings[index],
                  compact: !useTableLayout,
                ),
                if (index == holdings.length - 1)
                  const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    ];
  }
}

class PortfolioWalletHoldingsTitle extends StatelessWidget {
  const PortfolioWalletHoldingsTitle({
    super.key,
    required this.useTableLayout,
  });

  final bool useTableLayout;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Text(
      loc.portfolioWalletHoldings,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _WalletHoldingsMobileBody extends StatelessWidget {
  const _WalletHoldingsMobileBody({required this.holdings});

  final List<PortfolioHolding> holdings;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: holdings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return PortfolioWalletHoldingRow(
          holding: holdings[index],
          compact: true,
        );
      },
    );
  }
}

class _WalletHoldingsTableBody extends StatelessWidget {
  const _WalletHoldingsTableBody({required this.holdings});

  final List<PortfolioHolding> holdings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _WalletHoldingsTableHeader(),
        const Divider(height: 1),
        for (var i = 0; i < holdings.length; i++) ...[
          if (i > 0) const Divider(height: 1),
          PortfolioWalletHoldingRow(
            holding: holdings[i],
            compact: false,
          ),
        ],
      ],
    );
  }
}

class _WalletHoldingsTableHeader extends StatelessWidget {
  const _WalletHoldingsTableHeader();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w700,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(loc.portfolioAssets, style: headerStyle)),
          Expanded(
            flex: 2,
            child: Text(loc.portfolioTokenBalance, style: headerStyle),
          ),
          Expanded(
            flex: 2,
            child: Text(loc.portfolioCurrentPrice, style: headerStyle),
          ),
          Expanded(
            flex: 2,
            child: Text(loc.portfolioUsdValue, style: headerStyle),
          ),
        ],
      ),
    );
  }
}

class PortfolioWalletHoldingRow extends StatelessWidget {
  const PortfolioWalletHoldingRow({
    super.key,
    required this.holding,
    required this.compact,
  });

  final PortfolioHolding holding;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final symbol = portfolioHoldingSymbol(holding);
    final networkName = portfolioHoldingNetworkName(holding);
    final address = portfolioHoldingAddress(holding);
    final balance = formatPortfolioHoldingBalance(
      holding,
      unavailableLabel: loc.portfolioValueUnavailable,
    );

    final decoration = BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(compact ? 14 : 0),
      border: compact
          ? Border.all(color: theme.colorScheme.outlineVariant)
          : null,
    );

    final content = compact
        ? _MobileHoldingLayout(
            symbol: symbol,
            networkName: networkName,
            address: address,
            balance: balance,
            holding: holding,
            loc: loc,
            theme: theme,
          )
        : _DesktopHoldingLayout(
            symbol: symbol,
            networkName: networkName,
            address: address,
            balance: balance,
            holding: holding,
            theme: theme,
          );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: decoration,
      child: content,
    );
  }
}

class _MobileHoldingLayout extends StatelessWidget {
  const _MobileHoldingLayout({
    required this.symbol,
    required this.networkName,
    required this.address,
    required this.balance,
    required this.holding,
    required this.loc,
    required this.theme,
  });

  final String symbol;
  final String networkName;
  final String? address;
  final String balance;
  final PortfolioHolding holding;
  final AppLocalizations loc;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HoldingAssetHeader(
          holding: holding,
          symbol: symbol,
          networkName: networkName,
          address: address,
          theme: theme,
          titleStyle: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _LabeledMetric(label: loc.portfolioTokenBalance, value: balance),
        const SizedBox(height: 8),
        PortfolioPositionPriceValueRow(
          priceUsd: holding.priceUsd,
          priceStatus: holding.priceStatus,
          valueUsd: holding.valueUsd,
        ),
      ],
    );
  }
}

class _DesktopHoldingLayout extends StatelessWidget {
  const _DesktopHoldingLayout({
    required this.symbol,
    required this.networkName,
    required this.address,
    required this.balance,
    required this.holding,
    required this.theme,
  });

  final String symbol;
  final String networkName;
  final String? address;
  final String balance;
  final PortfolioHolding holding;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _HoldingAssetHeader(
            holding: holding,
            symbol: symbol,
            networkName: networkName,
            address: address,
            theme: theme,
            titleStyle: theme.textTheme.titleSmall,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            balance,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: PortfolioPositionPriceCell(
            priceUsd: holding.priceUsd,
            priceStatus: holding.priceStatus,
            compact: true,
          ),
        ),
        Expanded(
          flex: 2,
          child: PortfolioPositionValueCell(valueUsd: holding.valueUsd),
        ),
      ],
    );
  }
}

class _HoldingAssetHeader extends StatelessWidget {
  const _HoldingAssetHeader({
    required this.holding,
    required this.symbol,
    required this.networkName,
    required this.address,
    required this.theme,
    required this.titleStyle,
  });

  final PortfolioHolding holding;
  final String symbol;
  final String networkName;
  final String? address;
  final ThemeData theme;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TokenIcon(
          logoUrl: holding.logoUrl,
          symbol: symbol,
          size: PortfolioDefiTableLayout.assetIconSize,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                symbol,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: titleStyle?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                networkName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (address != null) ...[
                const SizedBox(height: 2),
                Text(
                  shortenPortfolioAddress(address!),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LabeledMetric extends StatelessWidget {
  const _LabeledMetric({
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

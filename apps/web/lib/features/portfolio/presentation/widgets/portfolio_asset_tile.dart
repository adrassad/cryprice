import 'package:cryprice_frontend/core/widgets/token_icon.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_defi_layout.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_formatters.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_price_status_chip.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_wallet_breakdown_tile.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PortfolioAssetTile extends StatelessWidget {
  const PortfolioAssetTile({
    super.key,
    required this.asset,
  });

  final PortfolioAsset asset;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final address = asset.address;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TokenIcon(
                logoUrl: asset.logoUrl,
                symbol: asset.symbol,
                size: PortfolioDefiTableLayout.assetIconSize,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.symbol,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (address != null && address.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        shortenPortfolioAddress(address),
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
              PortfolioPriceStatusChip(status: asset.priceStatus),
            ],
          ),
          const SizedBox(height: 12),
          _AssetField(
            label: loc.portfolioTokenBalance,
            value: formatPortfolioBalance(
              balance: asset.balance,
              symbol: asset.symbol,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _AssetField(
                label: loc.portfolioTokenPrice,
                value: formatPortfolioUsdForPriceStatus(
                  valueUsd: asset.priceUsd,
                  priceStatus: asset.priceStatus,
                  unavailableLabel: loc.portfolioPriceUnavailable,
                ),
              ),
              _AssetField(
                label: loc.portfolioTokenValue,
                value: formatPortfolioUsdForPriceStatus(
                  valueUsd: asset.valueUsd,
                  priceStatus: asset.priceStatus,
                  unavailableLabel: loc.portfolioValueUnavailable,
                ),
              ),
            ],
          ),
          if (asset.wallets.isNotEmpty) ...[
            const SizedBox(height: 8),
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(top: 4),
                title: Text(
                  '${loc.portfolioWalletBreakdown} (${asset.wallets.length})',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                children: _walletTiles(asset.wallets),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _walletTiles(List<PortfolioWalletBreakdown> wallets) {
    final widgets = <Widget>[];
    for (var i = 0; i < wallets.length; i++) {
      if (i > 0) {
        widgets.add(const SizedBox(height: 8));
      }
      widgets.add(
        PortfolioWalletBreakdownTile(
          wallet: wallets[i],
          assetSymbol: asset.symbol,
        ),
      );
    }
    return widgets;
  }
}

class _AssetField extends StatelessWidget {
  const _AssetField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

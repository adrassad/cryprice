import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_formatters.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PortfolioWalletBreakdownTile extends StatelessWidget {
  const PortfolioWalletBreakdownTile({
    super.key,
    required this.wallet,
    required this.assetSymbol,
  });

  final PortfolioWalletBreakdown wallet;
  final String assetSymbol;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final label = wallet.label?.trim();
    final hasLabel = label != null && label.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasLabel ? label : shortenPortfolioAddress(wallet.address),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (hasLabel) ...[
            const SizedBox(height: 2),
            Text(
              shortenPortfolioAddress(wallet.address),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _WalletField(
                label: loc.portfolioTokenBalance,
                value: formatPortfolioBalance(
                  balance: wallet.balance,
                  symbol: assetSymbol,
                ),
              ),
              _WalletField(
                label: loc.portfolioTokenValue,
                value: formatPortfolioUsd(
                  wallet.valueUsd,
                  unavailableLabel: loc.portfolioPriceUnavailable,
                ),
              ),
              if (wallet.syncedAt != null && wallet.syncedAt!.isNotEmpty)
                _WalletField(
                  label: loc.portfolioSyncedAt,
                  value: formatPortfolioUpdatedAt(
                    wallet.syncedAt!,
                    updatedNeverLabel: loc.portfolioUpdatedNever,
                  ),
                ),
              if (wallet.blockNumber != null)
                _WalletField(
                  label: loc.portfolioBlockNumber,
                  value: '${wallet.blockNumber}',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletField extends StatelessWidget {
  const _WalletField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

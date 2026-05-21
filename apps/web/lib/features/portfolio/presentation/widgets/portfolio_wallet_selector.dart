import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/utils/portfolio_wallet_selector_options.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_wallet_chip.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PortfolioWalletSelector extends StatelessWidget {
  const PortfolioWalletSelector({
    super.key,
    required this.portfolio,
    required this.selectedWalletId,
    required this.useCompactFilters,
  });

  final Portfolio portfolio;
  final String selectedWalletId;
  final bool useCompactFilters;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final options = buildPortfolioWalletSelectorOptions(
      portfolio: portfolio,
      loc: loc,
    );
    final normalizedSelection = PortfolioFilter.normalizeWalletId(selectedWalletId);

    if (options.length <= 1) {
      return const SizedBox.shrink();
    }

    final chips = options
        .map(
          (option) => PortfolioWalletChip(
            key: ValueKey<String>('portfolio-wallet-${option.walletId}'),
            option: option,
            isSelected: normalizedSelection == option.walletId,
            onTap: () => context.read<PortfolioCubit>().selectWallet(
              option.walletId == PortfolioFilter.allWallets
                  ? null
                  : option.walletId,
            ),
          ),
        )
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.portfolioWallets,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        if (useCompactFilters)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < chips.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  chips[i],
                ],
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips,
          ),
      ],
    );
  }
}

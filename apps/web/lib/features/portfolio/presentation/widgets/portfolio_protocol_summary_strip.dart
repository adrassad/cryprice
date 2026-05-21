import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/utils/portfolio_protocol_summary_options.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_protocol_summary_card.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PortfolioProtocolSummaryStrip extends StatelessWidget {
  const PortfolioProtocolSummaryStrip({
    super.key,
    required this.portfolio,
    required this.selectedProtocol,
    required this.useCompactFilters,
  });

  final Portfolio portfolio;
  final String selectedProtocol;
  final bool useCompactFilters;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final options = buildPortfolioProtocolStripOptions(
      portfolio: portfolio,
      loc: loc,
    );
    final normalizedSelection = PortfolioFilter.normalizeProtocol(selectedProtocol);

    if (options.length <= 1) {
      return const SizedBox.shrink();
    }

    final cards = options
        .map(
          (option) => PortfolioProtocolSummaryCard(
            key: ValueKey<String>('portfolio-protocol-${option.protocolId}'),
            option: option,
            isSelected: normalizedSelection == option.protocolId,
            valueLabel: _valueLabel(loc, option.protocolId),
            onTap: () => context.read<PortfolioCubit>().selectProtocol(
              option.protocolId,
            ),
          ),
        )
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.portfolioProtocols,
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
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  cards[i],
                ],
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cards,
          ),
      ],
    );
  }

  String? _valueLabel(AppLocalizations loc, String protocolId) {
    if (protocolId == PortfolioFilter.allProtocols) {
      return loc.portfolioNetValue;
    }
    if (protocolId == PortfolioFilter.walletProtocol) {
      return loc.portfolioWalletValue;
    }
    return loc.portfolioTotal;
  }
}

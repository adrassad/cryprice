import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filtered_view.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/cubit/portfolio_state.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_allocation_section.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_export_pdf_button.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_network_card.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_summary_card.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_defi_positions_section.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_protocol_summary_strip.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_risk_details_section.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_wallet_holdings_section.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_wallet_selector.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Body-only portfolio section for the shell tab.
class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<PortfolioCubit, PortfolioState>(
          listenWhen: (previous, current) =>
              previous.exportPdfSuccessTick != current.exportPdfSuccessTick &&
              current.exportPdfSuccessTick > 0,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(loc.portfolioExportPdfDownloaded)),
            );
          },
        ),
        BlocListener<PortfolioCubit, PortfolioState>(
          listenWhen: (previous, current) =>
              previous.exportPdfError != current.exportPdfError &&
              current.exportPdfError != null &&
              current.exportPdfError!.isNotEmpty,
          listener: (context, state) {
            final message = state.errorCode == 'UNAUTHENTICATED'
                ? loc.loginRequired
                : loc.portfolioExportPdfFailed;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          },
        ),
      ],
      child: BlocConsumer<PortfolioCubit, PortfolioState>(
        listenWhen: (previous, current) {
          return current.portfolio != null &&
              current.errorMessage != null &&
              previous.errorMessage != current.errorMessage;
        },
        listener: (context, state) {
          final message = state.errorMessage;
          if (message == null || message.isEmpty) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
        builder: (context, state) {
        final portfolio = state.portfolio;
        if ((state.status == PortfolioStatus.loaded ||
                state.status == PortfolioStatus.refreshing) &&
            portfolio != null) {
          return _PortfolioLoadedView(
            portfolio: portfolio,
            selectedProtocol: state.selectedProtocol,
            selectedWalletId: state.selectedWalletId,
            isRefreshing: state.status == PortfolioStatus.refreshing,
            isExportingPdf: state.isExportingPdf,
          );
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.pie_chart_outline,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  loc.portfolioTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                switch (state.status) {
                  PortfolioStatus.initial ||
                  PortfolioStatus.loading => const CircularProgressIndicator(),
                  PortfolioStatus.empty => _PortfolioEmptyState(
                      onRefresh: () => context.read<PortfolioCubit>().refresh(),
                    ),
                  PortfolioStatus.unauthenticated => _PortfolioMessageWithRetry(
                      message: loc.loginRequired,
                      onRetry: () => context.read<PortfolioCubit>().load(),
                    ),
                  PortfolioStatus.error ||
                  PortfolioStatus.loaded ||
                  PortfolioStatus.refreshing => _PortfolioMessageWithRetry(
                      message: state.errorMessage ?? loc.portfolioLoadFailed,
                      onRetry: () => context.read<PortfolioCubit>().load(),
                    ),
                },
              ],
            ),
          ),
        );
        },
      ),
    );
  }
}

class _PortfolioEmptyState extends StatelessWidget {
  const _PortfolioEmptyState({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          loc.portfolioNoAssets,
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            height: 1.4,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          loc.portfolioEmptyHint,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: onRefresh,
          child: Text(loc.portfolioPullToRefresh),
        ),
      ],
    );
  }
}

class _PortfolioLoadedView extends StatelessWidget {
  const _PortfolioLoadedView({
    required this.portfolio,
    required this.selectedProtocol,
    required this.selectedWalletId,
    required this.isRefreshing,
    required this.isExportingPdf,
  });

  final Portfolio portfolio;
  final String selectedProtocol;
  final String selectedWalletId;
  final bool isRefreshing;
  final bool isExportingPdf;

  @override
  Widget build(BuildContext context) {
    final filteredView = buildFilteredPortfolioView(
      portfolio,
      selectedProtocol,
      selectedWalletId,
    );

    return RefreshIndicator(
      onRefresh: () => context.read<PortfolioCubit>().refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final useCompactExport = constraints.maxWidth < 480;
              return Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  PortfolioExportPdfButton(
                    isExporting: isExportingPdf,
                    compact: useCompactExport,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          PortfolioAllocationSection(
            portfolio: portfolio,
            selectedWalletId: selectedWalletId,
            selectedProtocol: selectedProtocol,
          ),
          if (portfolio.hasAllocation) const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final useCompactFilters = width < 600;
              final useTableLayout = width >= 600;
              final useStackedGroupHeader = width < 520;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PortfolioProtocolSummaryStrip(
                    portfolio: portfolio,
                    selectedProtocol: selectedProtocol,
                    useCompactFilters: useCompactFilters,
                  ),
                  const SizedBox(height: 12),
                  PortfolioWalletSelector(
                    portfolio: portfolio,
                    selectedWalletId: selectedWalletId,
                    useCompactFilters: useCompactFilters,
                  ),
                  const SizedBox(height: 12),
                  PortfolioSummaryCard(
                    summary: portfolio.summary,
                    filteredView: filteredView,
                    selectedProtocol: selectedProtocol,
                    selectedWalletId: selectedWalletId,
                    isRefreshing: isRefreshing,
                  ),
                  const SizedBox(height: 12),
                  ..._portfolioBodySections(
                    portfolio,
                    filteredView,
                    useTableLayout: useTableLayout,
                    useStackedGroupHeader: useStackedGroupHeader,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _portfolioBodySections(
    Portfolio portfolio,
    PortfolioFilteredView filteredView, {
    required bool useTableLayout,
    required bool useStackedGroupHeader,
  }) {
    final sections = <Widget>[
      ..._walletHoldingsOrLegacyNetworkCards(
        portfolio,
        filteredView,
        selectedWalletId,
        useTableLayout: useTableLayout,
      ),
    ];

    if (filteredView.hasVisibleDefiPositions) {
      if (sections.isNotEmpty) {
        sections.add(const SizedBox(height: 12));
      }
      sections.add(
        PortfolioDefiPositionsSection(
          supplied: portfolio.protocolPositions.supplied,
          borrowed: portfolio.protocolPositions.borrowed,
          positionsHealth: portfolio.defiRisk.positionsHealth,
          protocolSummaries: portfolio.protocolSummaries,
          selectedProtocol: selectedProtocol,
          selectedWalletId: selectedWalletId,
          useTableLayout: useTableLayout,
          useStackedGroupHeader: useStackedGroupHeader,
        ),
      );
    } else if (!PortfolioFilter.isWalletProtocol(selectedProtocol) &&
        !filteredView.hasVisibleDefiPositions) {
      if (sections.isNotEmpty) {
        sections.add(const SizedBox(height: 12));
      }
      sections.add(const _NoDefiPositionsCard());
    }

    sections.addAll(_riskDetailsSections(portfolio, filteredView));

    return sections;
  }

  List<Widget> _riskDetailsSections(
    Portfolio portfolio,
    PortfolioFilteredView filteredView,
  ) {
    if (filteredView.visiblePositionsHealth.isNotEmpty) {
      return [
        const SizedBox(height: 12),
        PortfolioRiskDetailsSection(
          positionsHealth: filteredView.visiblePositionsHealth,
        ),
      ];
    }

    if (filteredView.visibleBorrowedPositions.isNotEmpty) {
      return [
        const SizedBox(height: 12),
        const PortfolioRiskDetailsUnavailableCard(),
      ];
    }

    return const <Widget>[];
  }

  List<Widget> _walletHoldingsOrLegacyNetworkCards(
    Portfolio portfolio,
    PortfolioFilteredView filteredView,
    String selectedWalletId, {
    required bool useTableLayout,
  }) {
    if (filteredView.hasVisibleWalletHoldings) {
      return [
        PortfolioWalletHoldingsSection(
          holdings: filteredView.visibleWalletHoldings,
          useTableLayout: useTableLayout,
        ),
      ];
    }

    if (portfolio.hasLegacyNetworkAssets &&
        PortfolioFilter.isAllProtocols(selectedProtocol) &&
        PortfolioFilter.isAllWallets(selectedWalletId)) {
      return _networkCards(portfolio.networks);
    }

    return [
      const _NoWalletHoldingsCard(),
    ];
  }

  List<Widget> _networkCards(List<PortfolioNetwork> networks) {
    final widgets = <Widget>[];
    for (var i = 0; i < networks.length; i++) {
      if (i > 0) {
        widgets.add(const SizedBox(height: 12));
      }
      widgets.add(PortfolioNetworkCard(network: networks[i]));
    }
    return widgets;
  }
}

class _NoWalletHoldingsCard extends StatelessWidget {
  const _NoWalletHoldingsCard();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          loc.portfolioNoWalletHoldings,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _NoDefiPositionsCard extends StatelessWidget {
  const _NoDefiPositionsCard();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          loc.portfolioNoDefiPositions,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _PortfolioMessageWithRetry extends StatelessWidget {
  const _PortfolioMessageWithRetry({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            height: 1.4,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: onRetry,
          child: Text(AppLocalizations.of(context)!.portfolioRetry),
        ),
      ],
    );
  }
}

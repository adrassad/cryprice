import 'package:cryprice_frontend/core/network/api_error_localizer.dart';
import 'package:cryprice_frontend/core/shell/shell_visuals.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/cubit/health_factor_calculator_cubit.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/cubit/health_factor_calculator_state.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/widgets/health_factor_calculator_form.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/widgets/health_factor_empty_state.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/widgets/health_factor_error_view.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/widgets/health_factor_result_card.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Health Factor Calculator body for the shell HF tab.
class HealthFactorPage extends StatelessWidget {
  const HealthFactorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocConsumer<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
      listenWhen: (previous, current) =>
          previous.status != current.status && current.status == HealthFactorCalculatorStatus.error,
      listener: (context, state) {
        if (state.status == HealthFactorCalculatorStatus.error && !state.hasMarket) {
          // Full-page error is shown in builder.
        }
      },
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state.status == HealthFactorCalculatorStatus.unauthenticated) {
          return HealthFactorErrorView(
            key: const Key('hf_calc_unauthenticated'),
            title: loc.hfCalcUnauthenticatedTitle,
            message: state.errorMessage ?? loc.hfCalcUnauthenticatedMessage,
            errorCode: state.errorCode,
          );
        }

        if (_isCatalogLoading(state.status)) {
          return _LoadingView(message: loc.hfCalcLoading);
        }

        if (state.status == HealthFactorCalculatorStatus.error) {
          return HealthFactorErrorView(
            key: const Key('hf_calc_error'),
            title: loc.hfCalcErrorTitle,
            message: localizeApiError(
              loc,
              code: state.errorCode,
              message: state.errorMessage,
            ),
            errorCode: state.errorCode,
            retryLabel: loc.hfCalcRetry,
            onRetry: () => context.read<HealthFactorCalculatorCubit>().initialize(),
          );
        }

        if (state.status == HealthFactorCalculatorStatus.initial) {
          return const SizedBox.shrink();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= ShellVisuals.wideLayoutMinWidth;
            final form = _buildFormColumn(context, state, loc);
            final resultPanel = _buildResultPanel(context, state, loc);

            if (wide) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: constraints.maxWidth - 32,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: form),
                      const SizedBox(width: 16),
                      Expanded(child: resultPanel),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  form,
                  const SizedBox(height: 20),
                  resultPanel,
                ],
              ),
            );
          },
        );
      },
    );
  }

  bool _isCatalogLoading(HealthFactorCalculatorStatus status) {
    return status == HealthFactorCalculatorStatus.loadingProtocols ||
        status == HealthFactorCalculatorStatus.loadingNetworks ||
        status == HealthFactorCalculatorStatus.loadingMarkets;
  }

  Widget _buildFormColumn(
    BuildContext context,
    HealthFactorCalculatorState state,
    AppLocalizations loc,
  ) {
    if (state.protocols.isEmpty) {
      return HealthFactorEmptyState(
        key: const Key('hf_calc_empty_protocols'),
        title: loc.hfCalcNoProtocolsTitle,
        subtitle: loc.hfCalcNoProtocolsSubtitle,
        icon: Icons.layers_outlined,
      );
    }

    if (state.selectedProtocol != null && state.networks.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HealthFactorCalculatorForm(),
          const SizedBox(height: 16),
          HealthFactorEmptyState(
            key: const Key('hf_calc_empty_networks'),
            title: loc.hfCalcNoNetworksTitle,
            subtitle: loc.hfCalcNoNetworksSubtitle,
            icon: Icons.hub_outlined,
          ),
        ],
      );
    }

    if (state.selectedNetwork != null && !state.hasMarket) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HealthFactorCalculatorForm(),
          const SizedBox(height: 16),
          HealthFactorEmptyState(
            key: const Key('hf_calc_empty_markets'),
            title: loc.hfCalcNoMarkets,
            icon: Icons.storefront_outlined,
          ),
        ],
      );
    }

    return const HealthFactorCalculatorForm();
  }

  Widget _buildResultPanel(
    BuildContext context,
    HealthFactorCalculatorState state,
    AppLocalizations loc,
  ) {
    final result = state.result;
    if (result != null) {
      return HealthFactorResultCard(
        key: const Key('hf_calc_result'),
        result: result,
      );
    }

    return HealthFactorEmptyState(
      key: const Key('hf_calc_no_result'),
      title: loc.hfCalcNoResultTitle,
      subtitle: loc.hfCalcNoResultSubtitle,
      icon: Icons.monitor_heart_outlined,
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('hf_calc_loading'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }
}

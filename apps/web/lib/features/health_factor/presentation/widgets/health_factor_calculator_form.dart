import 'package:cryprice_frontend/features/health_factor/presentation/cubit/health_factor_calculator_cubit.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/cubit/health_factor_calculator_state.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/widgets/health_factor_network_selector.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/widgets/health_factor_position_rows_section.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/widgets/health_factor_protocol_selector.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HealthFactorCalculatorForm extends StatelessWidget {
  const HealthFactorCalculatorForm({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return BlocBuilder<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.canCalculate != current.canCalculate ||
          previous.errorCode != current.errorCode ||
          previous.errorMessage != current.errorMessage,
      builder: (context, state) {
        final cubit = context.read<HealthFactorCalculatorCubit>();
        final calculating = state.status == HealthFactorCalculatorStatus.calculating;
        final canCalculate = state.canCalculate && !calculating;
        final hasInlineError = state.errorCode != null &&
            (state.status == HealthFactorCalculatorStatus.ready ||
                state.status == HealthFactorCalculatorStatus.result);

        return Column(
          key: const Key('hf_calc_form'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const HealthFactorProtocolSelector(),
            const SizedBox(height: 12),
            const HealthFactorNetworkSelector(),
            const SizedBox(height: 20),
            const HealthFactorPositionRowsSection(
              kind: HealthFactorPositionSectionKind.supply,
            ),
            const SizedBox(height: 16),
            const HealthFactorPositionRowsSection(
              kind: HealthFactorPositionSectionKind.borrow,
            ),
            if (hasInlineError) ...[
              const SizedBox(height: 12),
              _InlineCalculateError(
                errorCode: state.errorCode,
                message: state.errorMessage ?? loc.hfCalcErrorTitle,
                onDismiss: cubit.clearError,
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('hf_calc_calculate'),
              onPressed: canCalculate ? cubit.calculate : null,
              child: calculating
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 10),
                        Text(loc.hfCalcCalculating),
                      ],
                    )
                  : Text(loc.hfCalcCalculate),
            ),
          ],
        );
      },
    );
  }
}

class _InlineCalculateError extends StatelessWidget {
  const _InlineCalculateError({
    required this.errorCode,
    required this.message,
    required this.onDismiss,
  });

  final String? errorCode;
  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (errorCode != null && errorCode!.trim().isNotEmpty)
                    Text(
                      errorCode!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  Text(
                    message,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onDismiss,
              icon: const Icon(Icons.close, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

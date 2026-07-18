import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_protocol.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/cubit/health_factor_calculator_cubit.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/cubit/health_factor_calculator_state.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HealthFactorProtocolSelector extends StatelessWidget {
  const HealthFactorProtocolSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return BlocBuilder<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
      buildWhen: (previous, current) =>
          previous.protocols != current.protocols ||
          previous.selectedProtocol != current.selectedProtocol,
      builder: (context, state) {
        final protocols = state.protocols;
        final selected = state.selectedProtocol;
        final enabled = protocols.length > 1;

        return DropdownButtonFormField<HealthFactorProtocol>(
          initialValue: selected,
          decoration: InputDecoration(
            labelText: loc.hfCalcProtocol,
            border: const OutlineInputBorder(),
          ),
          hint: Text(loc.hfCalcSelectProtocol),
          items: protocols
              .map(
                (protocol) => DropdownMenuItem<HealthFactorProtocol>(
                  value: protocol,
                  child: Text(protocol.name),
                ),
              )
              .toList(growable: false),
          onChanged: enabled
              ? (protocol) {
                  if (protocol != null) {
                    context.read<HealthFactorCalculatorCubit>().selectProtocol(protocol);
                  }
                }
              : null,
        );
      },
    );
  }
}

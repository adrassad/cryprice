import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_network.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/cubit/health_factor_calculator_cubit.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/cubit/health_factor_calculator_state.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HealthFactorNetworkSelector extends StatelessWidget {
  const HealthFactorNetworkSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return BlocBuilder<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
      buildWhen: (previous, current) =>
          previous.networks != current.networks ||
          previous.selectedNetwork != current.selectedNetwork,
      builder: (context, state) {
        final networks = state.networks;
        final selected = state.selectedNetwork;
        final enabled = networks.isNotEmpty;

        return DropdownButtonFormField<HealthFactorNetwork>(
          initialValue: selected,
          decoration: InputDecoration(
            labelText: loc.hfCalcNetwork,
            border: const OutlineInputBorder(),
          ),
          hint: Text(loc.hfCalcSelectNetwork),
          items: networks
              .map(
                (network) => DropdownMenuItem<HealthFactorNetwork>(
                  value: network,
                  child: Text(_networkLabel(network)),
                ),
              )
              .toList(growable: false),
          onChanged: enabled
              ? (network) {
                  if (network != null) {
                    context.read<HealthFactorCalculatorCubit>().selectNetwork(network);
                  }
                }
              : null,
        );
      },
    );
  }
}

String _networkLabel(HealthFactorNetwork network) {
  final native = network.nativeSymbol?.trim();
  if (native != null && native.isNotEmpty) {
    return '${network.name} ($native)';
  }
  return network.name;
}

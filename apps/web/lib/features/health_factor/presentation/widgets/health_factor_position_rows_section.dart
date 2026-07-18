import 'package:cryprice_frontend/features/health_factor/presentation/cubit/health_factor_calculator_cubit.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/cubit/health_factor_calculator_state.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/widgets/health_factor_position_row.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum HealthFactorPositionSectionKind { supply, borrow }

class HealthFactorPositionRowsSection extends StatelessWidget {
  const HealthFactorPositionRowsSection({
    super.key,
    required this.kind,
  });

  final HealthFactorPositionSectionKind kind;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isSupply = kind == HealthFactorPositionSectionKind.supply;
    final title = isSupply ? loc.hfCalcSupplySection : loc.hfCalcBorrowSection;
    final addLabel = isSupply ? loc.hfCalcAddSupply : loc.hfCalcAddBorrow;

    return BlocBuilder<HealthFactorCalculatorCubit, HealthFactorCalculatorState>(
      buildWhen: (previous, current) =>
          previous.supplies != current.supplies ||
          previous.borrows != current.borrows ||
          previous.market != current.market,
      builder: (context, state) {
        final cubit = context.read<HealthFactorCalculatorCubit>();
        final theme = Theme.of(context);

        if (isSupply) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...state.supplies.map((row) {
                final reserves = row.useAsCollateral
                    ? state.collateralReserves
                    : state.supplyReserves;
                return HealthFactorPositionRow(
                  key: ValueKey<String>(row.id),
                  reserves: reserves,
                  supplyDraft: row,
                  marketPriceUsd: state.marketPriceUsdForSupplyDraft(row),
                  callbacks: (
                    onAssetChanged: (assetId) =>
                        cubit.updateSupplyAsset(row.id, assetId),
                    onAmountChanged: (amount) =>
                        cubit.updateSupplyAmount(row.id, amount),
                    onRemove: () => cubit.removeSupplyRow(row.id),
                    onUseAsCollateralChanged: (value) =>
                        cubit.updateSupplyUseAsCollateral(row.id, value),
                    onUseMarketPriceChanged: (value) =>
                        cubit.updateSupplyUseMarketPrice(row.id, value),
                    onCustomPriceChanged: (value) =>
                        cubit.updateSupplyCustomPrice(row.id, value),
                  ),
                );
              }),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const Key('hf_calc_add_supply'),
                  onPressed: state.hasMarket ? cubit.addSupplyRow : null,
                  icon: const Icon(Icons.add),
                  label: Text(addLabel),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...state.borrows.map((row) {
              return HealthFactorPositionRow(
                key: ValueKey<String>(row.id),
                reserves: state.borrowReserves,
                borrowDraft: row,
                marketPriceUsd: state.marketPriceUsdForBorrowDraft(row),
                callbacks: (
                  onAssetChanged: (assetId) =>
                      cubit.updateBorrowAsset(row.id, assetId),
                  onAmountChanged: (amount) =>
                      cubit.updateBorrowAmount(row.id, amount),
                  onRemove: () => cubit.removeBorrowRow(row.id),
                  onUseAsCollateralChanged: null,
                  onUseMarketPriceChanged: (value) =>
                      cubit.updateBorrowUseMarketPrice(row.id, value),
                  onCustomPriceChanged: (value) =>
                      cubit.updateBorrowCustomPrice(row.id, value),
                ),
              );
            }),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const Key('hf_calc_add_borrow'),
                onPressed: state.hasMarket ? cubit.addBorrowRow : null,
                icon: const Icon(Icons.add),
                label: Text(addLabel),
              ),
            ),
          ],
        );
      },
    );
  }
}

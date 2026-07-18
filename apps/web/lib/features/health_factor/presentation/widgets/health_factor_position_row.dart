import 'package:cryprice_frontend/core/widgets/token_icon.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_market_reserve.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/cubit/health_factor_calculator_state.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/utils/health_factor_risk_display.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef HealthFactorPositionRowCallbacks = ({
  void Function(String? assetId) onAssetChanged,
  void Function(String amount) onAmountChanged,
  VoidCallback onRemove,
  void Function(bool value)? onUseAsCollateralChanged,
  void Function(bool value) onUseMarketPriceChanged,
  void Function(String value) onCustomPriceChanged,
});

class HealthFactorPositionRow extends StatelessWidget {
  const HealthFactorPositionRow({
    super.key,
    required this.reserves,
    this.supplyDraft,
    this.borrowDraft,
    required this.callbacks,
    this.marketPriceUsd,
  }) : assert(
          (supplyDraft != null) ^ (borrowDraft != null),
          'Provide either supply or borrow draft',
        );

  final List<HealthFactorMarketReserve> reserves;
  final HealthFactorSupplyDraft? supplyDraft;
  final HealthFactorBorrowDraft? borrowDraft;
  final HealthFactorPositionRowCallbacks callbacks;
  final String? marketPriceUsd;

  bool get _hasSelectedAsset {
    final id = supplyDraft?.assetId ?? borrowDraft?.assetId;
    return id != null && id.trim().isNotEmpty;
  }

  bool get _useMarketPrice =>
      supplyDraft?.useMarketPrice ?? borrowDraft?.useMarketPrice ?? true;

  String get _customPriceUsd =>
      supplyDraft?.customPriceUsd ?? borrowDraft?.customPriceUsd ?? '';

  String get _rowId => supplyDraft?.id ?? borrowDraft!.id;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final selectedAssetId = supplyDraft?.assetId ?? borrowDraft?.assetId;
    final amount = supplyDraft?.amount ?? borrowDraft?.amount ?? '';
    final selectedReserve = _selectedReserve(selectedAssetId);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_hasSelectedAsset) ...[
                  TokenIcon(
                    logoUrl: selectedReserve?.asset.logoUrl,
                    symbol: selectedReserve?.asset.symbol ?? '',
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _dropdownValue(selectedAssetId, reserves),
                    decoration: InputDecoration(
                      labelText: loc.hfCalcAsset,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: '',
                        child: Text(loc.hfCalcSelectAsset),
                      ),
                      ...reserves.map(_assetMenuItem),
                    ],
                    onChanged: (value) {
                      final assetId = value?.trim();
                      callbacks.onAssetChanged(
                        assetId == null || assetId.isEmpty ? null : assetId,
                      );
                    },
                  ),
                ),
                IconButton(
                  tooltip: loc.hfCalcRemoveRow,
                  onPressed: callbacks.onRemove,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            if (_hasSelectedAsset) ...[
              const SizedBox(height: 10),
              _PriceLine(
                key: Key('hf_calc_current_price_$_rowId'),
                label: loc.hfCalcCurrentPrice,
                value: healthFactorCalcFormatUsd(
                  marketPriceUsd,
                  unavailable: loc.hfCalcPriceUnavailable,
                ),
              ),
              CheckboxListTile(
                key: Key('hf_calc_use_market_price_$_rowId'),
                contentPadding: EdgeInsets.zero,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  loc.hfCalcUseMarketPrice,
                  style: theme.textTheme.bodyMedium,
                ),
                value: _useMarketPrice,
                onChanged: (value) {
                  if (value != null) {
                    callbacks.onUseMarketPriceChanged(value);
                  }
                },
              ),
              if (!_useMarketPrice) ...[
                const SizedBox(height: 4),
                TextFormField(
                  key: Key('hf_calc_custom_price_$_rowId'),
                  initialValue: _customPriceUsd,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: InputDecoration(
                    labelText: loc.hfCalcCustomPrice,
                    border: const OutlineInputBorder(),
                    isDense: true,
                    helperText: loc.hfCalcSimulationOnly,
                  ),
                  onChanged: callbacks.onCustomPriceChanged,
                ),
              ],
            ],
            const SizedBox(height: 10),
            TextFormField(
              key: ValueKey<String>('hf-amount-$_rowId'),
              initialValue: amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: InputDecoration(
                labelText: loc.hfCalcAmount,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: callbacks.onAmountChanged,
            ),
            if (supplyDraft != null && callbacks.onUseAsCollateralChanged != null) ...[
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  loc.hfCalcUseAsCollateral,
                  style: theme.textTheme.bodyMedium,
                ),
                value: supplyDraft!.useAsCollateral,
                onChanged: callbacks.onUseAsCollateralChanged,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String? _dropdownValue(
    String? assetId,
    List<HealthFactorMarketReserve> reserves,
  ) {
    final trimmed = assetId?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return '';
    }
    final exists = reserves.any((reserve) => reserve.asset.id == trimmed);
    return exists ? trimmed : '';
  }

  static DropdownMenuItem<String> _assetMenuItem(HealthFactorMarketReserve reserve) {
    final asset = reserve.asset;
    return DropdownMenuItem<String>(
      value: asset.id,
      child: Text(
        asset.symbol,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  HealthFactorMarketReserve? _selectedReserve(String? assetId) {
    final trimmed = assetId?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    for (final reserve in reserves) {
      if (reserve.asset.id == trimmed) {
        return reserve;
      }
    }
    return null;
  }
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

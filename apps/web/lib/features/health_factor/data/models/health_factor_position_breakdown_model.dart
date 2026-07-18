import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_json_parsing.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_position_breakdown.dart';

class HealthFactorPositionBreakdownModel {
  const HealthFactorPositionBreakdownModel({
    this.assetId,
    this.address,
    this.symbol,
    this.amount,
    this.valueUsd,
    this.useAsCollateral,
    this.priceUsd,
    this.marketPriceUsd,
    this.customPriceUsd,
    this.priceSource,
  });

  final String? assetId;
  final String? address;
  final String? symbol;
  final String? amount;
  final String? valueUsd;
  final bool? useAsCollateral;
  final String? priceUsd;
  final String? marketPriceUsd;
  final String? customPriceUsd;
  final String? priceSource;

  factory HealthFactorPositionBreakdownModel.fromJson(Map<String, Object?> json) {
    final nestedAsset = hfNullableMapValue(json['asset']);
    return HealthFactorPositionBreakdownModel(
      assetId: hfNullableIdStringValue(json['assetId']) ??
          hfNullableIdStringValue(nestedAsset?['id']),
      address: hfNullableStringValue(json['address']) ??
          hfNullableStringValue(nestedAsset?['address']),
      symbol: hfNullableStringValue(json['symbol']) ??
          hfNullableStringValue(nestedAsset?['symbol']),
      amount: hfNullableStringValue(json['amount']),
      valueUsd: hfNullableStringValue(json['valueUsd']) ??
          hfNullableStringValue(json['usd']),
      useAsCollateral: json['useAsCollateral'] == null
          ? null
          : hfBoolValue(json['useAsCollateral']),
      priceUsd: hfNullableStringValue(json['priceUsd']),
      marketPriceUsd: hfNullableStringValue(json['marketPriceUsd']),
      customPriceUsd: hfNullableStringValue(json['customPriceUsd']),
      priceSource: hfNullableStringValue(json['priceSource']),
    );
  }

  HealthFactorPositionBreakdown toEntity() {
    return HealthFactorPositionBreakdown(
      assetId: assetId,
      address: address,
      symbol: symbol,
      amount: amount,
      valueUsd: valueUsd,
      useAsCollateral: useAsCollateral,
      priceUsd: priceUsd,
      marketPriceUsd: marketPriceUsd,
      customPriceUsd: customPriceUsd,
      priceSource: priceSource,
    );
  }

  static List<HealthFactorPositionBreakdownModel> listFromJson(Object? value) {
    return hfListValue(value)
        .map(HealthFactorPositionBreakdownModel.fromJson)
        .toList(growable: false);
  }
}

class HealthFactorPositionsBreakdownModel {
  const HealthFactorPositionsBreakdownModel({
    this.supplies = const <HealthFactorPositionBreakdownModel>[],
    this.borrows = const <HealthFactorPositionBreakdownModel>[],
  });

  final List<HealthFactorPositionBreakdownModel> supplies;
  final List<HealthFactorPositionBreakdownModel> borrows;

  factory HealthFactorPositionsBreakdownModel.fromJson(Map<String, Object?> json) {
    return HealthFactorPositionsBreakdownModel(
      supplies: HealthFactorPositionBreakdownModel.listFromJson(json['supplies']),
      borrows: HealthFactorPositionBreakdownModel.listFromJson(json['borrows']),
    );
  }

  HealthFactorPositionsBreakdown toEntity() {
    return HealthFactorPositionsBreakdown(
      supplies: supplies.map((row) => row.toEntity()).toList(growable: false),
      borrows: borrows.map((row) => row.toEntity()).toList(growable: false),
    );
  }
}

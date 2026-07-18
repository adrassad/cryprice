import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_json_parsing.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_network_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_position_breakdown_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_totals_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_warning_model.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_calculate_result.dart';

class HealthFactorCalculateResponseModel {
  const HealthFactorCalculateResponseModel({
    required this.protocol,
    required this.network,
    this.marketId,
    this.healthFactor,
    required this.healthFactorDisplay,
    this.isInfinite = false,
    required this.riskLevel,
    required this.totals,
    required this.positions,
    this.warnings = const <HealthFactorWarningModel>[],
    this.computedAt,
  });

  final String protocol;
  final HealthFactorNetworkModel network;
  final String? marketId;
  final String? healthFactor;
  final String healthFactorDisplay;
  final bool isInfinite;
  final String riskLevel;
  final HealthFactorTotalsModel totals;
  final HealthFactorPositionsBreakdownModel positions;
  final List<HealthFactorWarningModel> warnings;
  final String? computedAt;

  factory HealthFactorCalculateResponseModel.fromJson(Map<String, Object?> json) {
    final calculation = hfMapValue(json['calculation']);
    return HealthFactorCalculateResponseModel.fromCalculationJson(calculation);
  }

  factory HealthFactorCalculateResponseModel.fromCalculationJson(
    Map<String, Object?> json,
  ) {
    return HealthFactorCalculateResponseModel(
      protocol: hfIdStringValue(json['protocol']),
      network: HealthFactorNetworkModel.fromJson(hfMapValue(json['network'])),
      marketId: hfNullableIdStringValue(json['marketId']),
      healthFactor: hfNullableStringValue(json['healthFactor']),
      healthFactorDisplay: hfStringValue(json['healthFactorDisplay']),
      isInfinite: hfBoolValue(json['isInfinite']),
      riskLevel: hfStringValue(json['riskLevel']),
      totals: HealthFactorTotalsModel.fromJson(hfMapValue(json['totals'])),
      positions: HealthFactorPositionsBreakdownModel.fromJson(
        hfMapValue(json['positions']),
      ),
      warnings: HealthFactorWarningModel.listFromJson(json['warnings']),
      computedAt: hfNullableStringValue(json['computedAt']),
    );
  }

  static HealthFactorCalculateResponseModel fromResponseData(Object? data) {
    if (data is Map<String, Object?>) {
      return HealthFactorCalculateResponseModel.fromJson(data);
    }
    if (data is Map) {
      return HealthFactorCalculateResponseModel.fromJson(data.cast<String, Object?>());
    }
    return HealthFactorCalculateResponseModel.fromCalculationJson(const <String, Object?>{});
  }

  HealthFactorCalculateResult toEntity() {
    return HealthFactorCalculateResult(
      protocol: protocol,
      network: network.toEntity(),
      marketId: marketId,
      healthFactor: healthFactor,
      healthFactorDisplay: healthFactorDisplay,
      isInfinite: isInfinite,
      riskLevel: riskLevel,
      totals: totals.toEntity(),
      positions: positions.toEntity(),
      warnings: warnings.map((w) => w.toEntity()).toList(growable: false),
      computedAt: computedAt,
    );
  }
}

import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_json_parsing.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_risk.dart';

class HealthFactorRiskModel {
  const HealthFactorRiskModel({
    this.ltvBps,
    this.ltv,
    this.liquidationThresholdBps,
    this.liquidationThreshold,
    this.liquidationBonusBps,
    this.liquidationPenaltyBps,
  });

  final int? ltvBps;
  final String? ltv;
  final int? liquidationThresholdBps;
  final String? liquidationThreshold;
  final int? liquidationBonusBps;
  final int? liquidationPenaltyBps;

  factory HealthFactorRiskModel.fromJson(Map<String, Object?> json) {
    return HealthFactorRiskModel(
      ltvBps: hfNullableIntValue(json['ltvBps']),
      ltv: hfNullableStringValue(json['ltv']),
      liquidationThresholdBps: hfNullableIntValue(json['liquidationThresholdBps']),
      liquidationThreshold: hfNullableStringValue(json['liquidationThreshold']),
      liquidationBonusBps: hfNullableIntValue(json['liquidationBonusBps']),
      liquidationPenaltyBps: hfNullableIntValue(json['liquidationPenaltyBps']),
    );
  }

  HealthFactorRisk toEntity() {
    return HealthFactorRisk(
      ltvBps: ltvBps,
      ltv: ltv,
      liquidationThresholdBps: liquidationThresholdBps,
      liquidationThreshold: liquidationThreshold,
      liquidationBonusBps: liquidationBonusBps,
      liquidationPenaltyBps: liquidationPenaltyBps,
    );
  }
}

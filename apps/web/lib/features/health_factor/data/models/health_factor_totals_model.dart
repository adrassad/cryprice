import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_json_parsing.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_totals.dart';

class HealthFactorTotalsModel {
  const HealthFactorTotalsModel({
    required this.collateralUsd,
    required this.collateralWeightedUsd,
    required this.borrowUsd,
  });

  final String collateralUsd;
  final String collateralWeightedUsd;
  final String borrowUsd;

  factory HealthFactorTotalsModel.fromJson(Map<String, Object?> json) {
    return HealthFactorTotalsModel(
      collateralUsd: hfStringValue(json['collateralUsd']),
      collateralWeightedUsd: hfStringValue(json['collateralWeightedUsd']),
      borrowUsd: hfStringValue(json['borrowUsd']),
    );
  }

  HealthFactorTotals toEntity() {
    return HealthFactorTotals(
      collateralUsd: collateralUsd,
      collateralWeightedUsd: collateralWeightedUsd,
      borrowUsd: borrowUsd,
    );
  }
}

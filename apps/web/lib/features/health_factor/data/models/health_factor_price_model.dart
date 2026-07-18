import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_json_parsing.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_price.dart';

class HealthFactorPriceModel {
  const HealthFactorPriceModel({
    required this.usd,
    this.source,
    this.updatedAt,
    this.isStale = false,
  });

  final String usd;
  final String? source;
  final String? updatedAt;
  final bool isStale;

  factory HealthFactorPriceModel.fromJson(Map<String, Object?> json) {
    return HealthFactorPriceModel(
      usd: hfStringValue(json['usd']),
      source: hfNullableStringValue(json['source']),
      updatedAt: hfNullableStringValue(json['updatedAt']),
      isStale: hfBoolValue(json['isStale']),
    );
  }

  HealthFactorPrice toEntity() {
    return HealthFactorPrice(
      usd: usd,
      source: source,
      updatedAt: updatedAt,
      isStale: isStale,
    );
  }
}

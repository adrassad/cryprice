import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_json_parsing.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_asset.dart';

class HealthFactorAssetModel {
  const HealthFactorAssetModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.address,
    required this.decimals,
    this.logoUrl,
  });

  final String id;
  final String symbol;
  final String name;
  final String address;
  final int decimals;
  final String? logoUrl;

  factory HealthFactorAssetModel.fromJson(Map<String, Object?> json) {
    return HealthFactorAssetModel(
      id: hfIdStringValue(json['id']),
      symbol: hfStringValue(json['symbol']),
      name: hfStringValue(json['name']),
      address: hfStringValue(json['address']),
      decimals: hfIntValue(json['decimals']),
      logoUrl: hfNullableLogoUrl(json['logoUrl'] ?? json['logo_url']),
    );
  }

  HealthFactorAsset toEntity() {
    return HealthFactorAsset(
      id: id,
      symbol: symbol,
      name: name,
      address: address,
      decimals: decimals,
      logoUrl: logoUrl,
    );
  }
}

import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_asset_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_flags_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_json_parsing.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_network_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_price_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_risk_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_warning_model.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_market_reserve.dart';

class HealthFactorMarketReserveModel {
  const HealthFactorMarketReserveModel({
    required this.protocol,
    required this.network,
    this.marketId,
    required this.asset,
    required this.price,
    required this.risk,
    required this.flags,
    this.syncedAt,
    this.warnings = const <HealthFactorWarningModel>[],
  });

  final String protocol;
  final HealthFactorNetworkModel network;
  final String? marketId;
  final HealthFactorAssetModel asset;
  final HealthFactorPriceModel price;
  final HealthFactorRiskModel risk;
  final HealthFactorFlagsModel flags;
  final String? syncedAt;
  final List<HealthFactorWarningModel> warnings;

  factory HealthFactorMarketReserveModel.fromJson(Map<String, Object?> json) {
    return HealthFactorMarketReserveModel(
      protocol: hfIdStringValue(json['protocol']),
      network: HealthFactorNetworkModel.fromJson(hfMapValue(json['network'])),
      marketId: hfNullableIdStringValue(json['marketId']),
      asset: HealthFactorAssetModel.fromJson(hfMapValue(json['asset'])),
      price: HealthFactorPriceModel.fromJson(hfMapValue(json['price'])),
      risk: HealthFactorRiskModel.fromJson(hfMapValue(json['risk'])),
      flags: HealthFactorFlagsModel.fromJson(hfMapValue(json['flags'])),
      syncedAt: hfNullableStringValue(json['syncedAt']),
      warnings: HealthFactorWarningModel.listFromJson(json['warnings']),
    );
  }

  HealthFactorMarketReserve toEntity() {
    return HealthFactorMarketReserve(
      protocol: protocol,
      network: network.toEntity(),
      marketId: marketId,
      asset: asset.toEntity(),
      price: price.toEntity(),
      risk: risk.toEntity(),
      flags: flags.toEntity(),
      syncedAt: syncedAt,
      warnings: warnings.map((w) => w.toEntity()).toList(growable: false),
    );
  }
}

import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_json_parsing.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_market_reserve_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_network_model.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_markets_result.dart';

class HealthFactorMarketsResponseModel {
  const HealthFactorMarketsResponseModel({
    required this.protocol,
    required this.network,
    this.marketId,
    this.reserves = const <HealthFactorMarketReserveModel>[],
  });

  final String protocol;
  final HealthFactorNetworkModel network;
  final String? marketId;
  final List<HealthFactorMarketReserveModel> reserves;

  factory HealthFactorMarketsResponseModel.fromJson(Map<String, Object?> json) {
    final market = hfMapValue(json['market']);
    return HealthFactorMarketsResponseModel(
      protocol: hfIdStringValue(market['protocol']),
      network: HealthFactorNetworkModel.fromJson(hfMapValue(market['network'])),
      marketId: hfNullableIdStringValue(market['marketId']),
      reserves: hfListValue(market['reserves'])
          .map(HealthFactorMarketReserveModel.fromJson)
          .toList(growable: false),
    );
  }

  static HealthFactorMarketsResponseModel fromResponseData(Object? data) {
    if (data is Map<String, Object?>) {
      return HealthFactorMarketsResponseModel.fromJson(data);
    }
    if (data is Map) {
      return HealthFactorMarketsResponseModel.fromJson(data.cast<String, Object?>());
    }
    return const HealthFactorMarketsResponseModel(
      protocol: '',
      network: HealthFactorNetworkModel(id: 0, name: '', chainId: 0),
    );
  }

  HealthFactorMarketsResult toEntity() {
    return HealthFactorMarketsResult(
      protocol: protocol,
      network: network.toEntity(),
      marketId: marketId,
      reserves: reserves.map((r) => r.toEntity()).toList(growable: false),
    );
  }
}

import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_json_parsing.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_network.dart';

class HealthFactorNetworkModel {
  const HealthFactorNetworkModel({
    required this.id,
    required this.name,
    required this.chainId,
    this.nativeSymbol,
  });

  final int id;
  final String name;
  final int chainId;
  final String? nativeSymbol;

  factory HealthFactorNetworkModel.fromJson(Map<String, Object?> json) {
    return HealthFactorNetworkModel(
      id: hfIntValue(json['id']),
      name: hfStringValue(json['name']),
      chainId: hfIntValue(json['chainId']),
      nativeSymbol: hfNullableStringValue(json['nativeSymbol']),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'name': name,
        'chainId': chainId,
        if (nativeSymbol != null) 'nativeSymbol': nativeSymbol,
      };

  HealthFactorNetwork toEntity() {
    return HealthFactorNetwork(
      id: id.toString(),
      name: name,
      chainId: chainId,
      nativeSymbol: nativeSymbol,
    );
  }

  static List<HealthFactorNetworkModel> listFromResponse(Object? data) {
    if (data is! Map) {
      return const <HealthFactorNetworkModel>[];
    }
    final json = data.cast<String, Object?>();
    return hfListValue(json['networks'])
        .map(HealthFactorNetworkModel.fromJson)
        .toList(growable: false);
  }
}

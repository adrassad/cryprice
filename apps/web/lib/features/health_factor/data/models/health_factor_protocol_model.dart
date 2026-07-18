import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_json_parsing.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_protocol.dart';

class HealthFactorProtocolModel {
  const HealthFactorProtocolModel({
    required this.id,
    required this.name,
    this.version,
    this.hasReserveData = false,
  });

  final String id;
  final String name;
  final String? version;
  final bool hasReserveData;

  factory HealthFactorProtocolModel.fromJson(Map<String, Object?> json) {
    return HealthFactorProtocolModel(
      id: hfIdStringValue(json['id']),
      name: hfStringValue(json['name']),
      version: hfNullableStringValue(json['version']),
      hasReserveData: hfBoolValue(json['hasReserveData']),
    );
  }

  HealthFactorProtocol toEntity() {
    return HealthFactorProtocol(
      id: id,
      name: name,
      version: version,
      hasReserveData: hasReserveData,
    );
  }

  static List<HealthFactorProtocolModel> listFromResponse(Object? data) {
    if (data is! Map) {
      return const <HealthFactorProtocolModel>[];
    }
    final json = data.cast<String, Object?>();
    return hfListValue(json['protocols'])
        .map(HealthFactorProtocolModel.fromJson)
        .toList(growable: false);
  }
}

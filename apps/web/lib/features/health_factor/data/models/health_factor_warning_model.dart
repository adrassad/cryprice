import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_json_parsing.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_warning.dart';

class HealthFactorWarningModel {
  const HealthFactorWarningModel({
    this.code,
    this.message,
    this.raw,
  });

  final String? code;
  final String? message;

  /// Original backend value when not a structured object (plain string warning).
  final String? raw;

  factory HealthFactorWarningModel.fromJson(Object? value) {
    if (value == null) {
      return const HealthFactorWarningModel();
    }
    if (value is String) {
      final trimmed = value.trim();
      return HealthFactorWarningModel(
        message: trimmed.isEmpty ? null : trimmed,
        raw: trimmed.isEmpty ? null : trimmed,
      );
    }
    if (value is Map) {
      final json = value.cast<String, Object?>();
      return HealthFactorWarningModel(
        code: hfNullableStringValue(json['code']),
        message: hfNullableStringValue(json['message']),
      );
    }
    final asString = value.toString().trim();
    return HealthFactorWarningModel(
      message: asString.isEmpty ? null : asString,
      raw: asString.isEmpty ? null : asString,
    );
  }

  static List<HealthFactorWarningModel> listFromJson(Object? value) {
    if (value is! List) {
      return const <HealthFactorWarningModel>[];
    }
    return value.map(HealthFactorWarningModel.fromJson).toList(growable: false);
  }

  HealthFactorWarning toEntity() {
    return HealthFactorWarning(
      code: code,
      message: message,
      raw: raw,
    );
  }
}

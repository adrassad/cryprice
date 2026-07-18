import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_json_parsing.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_flags.dart';

class HealthFactorFlagsModel {
  const HealthFactorFlagsModel({
    this.supplyEnabled = false,
    this.borrowEnabled = false,
    this.collateralEnabled = false,
    this.isActive = false,
    this.isFrozen = false,
    this.isPaused = false,
  });

  final bool supplyEnabled;
  final bool borrowEnabled;
  final bool collateralEnabled;
  final bool isActive;
  final bool isFrozen;
  final bool isPaused;

  factory HealthFactorFlagsModel.fromJson(Map<String, Object?> json) {
    return HealthFactorFlagsModel(
      supplyEnabled: hfBoolValue(json['supplyEnabled']),
      borrowEnabled: hfBoolValue(json['borrowEnabled']),
      collateralEnabled: hfBoolValue(json['collateralEnabled']),
      isActive: hfBoolValue(json['isActive']),
      isFrozen: hfBoolValue(json['isFrozen']),
      isPaused: hfBoolValue(json['isPaused']),
    );
  }

  HealthFactorFlags toEntity() {
    return HealthFactorFlags(
      supplyEnabled: supplyEnabled,
      borrowEnabled: borrowEnabled,
      collateralEnabled: collateralEnabled,
      isActive: isActive,
      isFrozen: isFrozen,
      isPaused: isPaused,
    );
  }
}

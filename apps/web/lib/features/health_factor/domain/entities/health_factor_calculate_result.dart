import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_network.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_position_breakdown.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_totals.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_warning.dart';

class HealthFactorCalculateResult {
  const HealthFactorCalculateResult({
    required this.protocol,
    required this.network,
    this.marketId,
    this.healthFactor,
    required this.healthFactorDisplay,
    this.isInfinite = false,
    required this.riskLevel,
    required this.totals,
    required this.positions,
    this.warnings = const <HealthFactorWarning>[],
    this.computedAt,
  });

  final String protocol;
  final HealthFactorNetwork network;
  final String? marketId;
  final String? healthFactor;
  final String healthFactorDisplay;
  final bool isInfinite;
  final String riskLevel;
  final HealthFactorTotals totals;
  final HealthFactorPositionsBreakdown positions;
  final List<HealthFactorWarning> warnings;
  final String? computedAt;
}

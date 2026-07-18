import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_asset.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_flags.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_network.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_price.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_risk.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_warning.dart';

class HealthFactorMarketReserve {
  const HealthFactorMarketReserve({
    required this.protocol,
    required this.network,
    this.marketId,
    required this.asset,
    required this.price,
    required this.risk,
    required this.flags,
    this.syncedAt,
    this.warnings = const <HealthFactorWarning>[],
  });

  final String protocol;
  final HealthFactorNetwork network;
  final String? marketId;
  final HealthFactorAsset asset;
  final HealthFactorPrice price;
  final HealthFactorRisk risk;
  final HealthFactorFlags flags;
  final String? syncedAt;
  final List<HealthFactorWarning> warnings;
}

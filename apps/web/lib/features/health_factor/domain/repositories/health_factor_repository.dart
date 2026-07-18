import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_calculate_request.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_calculate_result.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_markets_result.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_network.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_protocol.dart';

abstract class HealthFactorRepository {
  Future<List<HealthFactorProtocol>> getProtocols();

  Future<List<HealthFactorNetwork>> getNetworks({required String protocol});

  Future<HealthFactorMarketsResult> getMarkets({
    required String protocol,
    required String network,
    String? marketId,
    bool? onlyActive,
    bool? onlySupplyEnabled,
    bool? onlyBorrowEnabled,
    bool? onlyCollateralEnabled,
    String? search,
  });

  Future<HealthFactorCalculateResult> calculate({
    required HealthFactorCalculateRequest request,
  });
}

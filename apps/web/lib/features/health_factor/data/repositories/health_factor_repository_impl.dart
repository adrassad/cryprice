import 'package:cryprice_frontend/features/health_factor/data/datasources/health_factor_remote_datasource.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_calculate_request_model.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_calculate_request.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_calculate_result.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_markets_result.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_network.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_protocol.dart';
import 'package:cryprice_frontend/features/health_factor/domain/repositories/health_factor_repository.dart';

class HealthFactorRepositoryImpl implements HealthFactorRepository {
  HealthFactorRepositoryImpl({required HealthFactorRemoteDataSource remote})
      : _remote = remote;

  final HealthFactorRemoteDataSource _remote;

  @override
  Future<List<HealthFactorProtocol>> getProtocols() async {
    final models = await _remote.getProtocols();
    return models.map((model) => model.toEntity()).toList(growable: false);
  }

  @override
  Future<List<HealthFactorNetwork>> getNetworks({required String protocol}) async {
    final models = await _remote.getNetworks(protocol: protocol);
    return models.map((model) => model.toEntity()).toList(growable: false);
  }

  @override
  Future<HealthFactorMarketsResult> getMarkets({
    required String protocol,
    required String network,
    String? marketId,
    bool? onlyActive,
    bool? onlySupplyEnabled,
    bool? onlyBorrowEnabled,
    bool? onlyCollateralEnabled,
    String? search,
  }) async {
    final model = await _remote.getMarkets(
      protocol: protocol,
      network: network,
      marketId: marketId,
      onlyActive: onlyActive,
      onlySupplyEnabled: onlySupplyEnabled,
      onlyBorrowEnabled: onlyBorrowEnabled,
      onlyCollateralEnabled: onlyCollateralEnabled,
      search: search,
    );
    return model.toEntity();
  }

  @override
  Future<HealthFactorCalculateResult> calculate({
    required HealthFactorCalculateRequest request,
  }) async {
    final response = await _remote.calculate(
      request: HealthFactorCalculateRequestModel.fromEntity(request),
      protocol: request.protocol,
    );
    return response.toEntity();
  }
}

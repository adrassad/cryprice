import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_markets_result.dart';
import 'package:cryprice_frontend/features/health_factor/domain/repositories/health_factor_repository.dart';

class GetHealthFactorMarketsUseCase {
  GetHealthFactorMarketsUseCase(this._repository);

  final HealthFactorRepository _repository;

  Future<HealthFactorMarketsResult> execute({
    required String protocol,
    required String network,
    String? marketId,
    bool? onlyActive,
    bool? onlySupplyEnabled,
    bool? onlyBorrowEnabled,
    bool? onlyCollateralEnabled,
    String? search,
  }) {
    return _repository.getMarkets(
      protocol: protocol,
      network: network,
      marketId: marketId,
      onlyActive: onlyActive,
      onlySupplyEnabled: onlySupplyEnabled,
      onlyBorrowEnabled: onlyBorrowEnabled,
      onlyCollateralEnabled: onlyCollateralEnabled,
      search: search,
    );
  }
}

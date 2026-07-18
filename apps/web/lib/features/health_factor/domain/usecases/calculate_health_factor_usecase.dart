import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_calculate_request.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_calculate_result.dart';
import 'package:cryprice_frontend/features/health_factor/domain/repositories/health_factor_repository.dart';

class CalculateHealthFactorUseCase {
  CalculateHealthFactorUseCase(this._repository);

  final HealthFactorRepository _repository;

  Future<HealthFactorCalculateResult> execute({
    required HealthFactorCalculateRequest request,
  }) =>
      _repository.calculate(request: request);
}

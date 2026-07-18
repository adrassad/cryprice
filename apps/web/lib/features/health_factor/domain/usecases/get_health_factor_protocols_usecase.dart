import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_protocol.dart';
import 'package:cryprice_frontend/features/health_factor/domain/repositories/health_factor_repository.dart';

class GetHealthFactorProtocolsUseCase {
  GetHealthFactorProtocolsUseCase(this._repository);

  final HealthFactorRepository _repository;

  Future<List<HealthFactorProtocol>> execute() => _repository.getProtocols();
}

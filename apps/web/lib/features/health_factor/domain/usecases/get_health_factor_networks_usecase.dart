import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_network.dart';
import 'package:cryprice_frontend/features/health_factor/domain/repositories/health_factor_repository.dart';

class GetHealthFactorNetworksUseCase {
  GetHealthFactorNetworksUseCase(this._repository);

  final HealthFactorRepository _repository;

  Future<List<HealthFactorNetwork>> execute({required String protocol}) =>
      _repository.getNetworks(protocol: protocol);
}

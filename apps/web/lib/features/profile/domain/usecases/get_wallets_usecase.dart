import 'package:cryprice_frontend/features/profile/domain/entities/wallet.dart';
import 'package:cryprice_frontend/features/profile/domain/repositories/profile_repository.dart';

class GetWalletsUseCase {
  GetWalletsUseCase(this._repository);

  final ProfileRepository _repository;

  Future<List<Wallet>> execute() => _repository.getWallets();
}

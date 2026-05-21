import 'package:cryprice_frontend/features/profile/domain/repositories/profile_repository.dart';

class DeleteWalletUseCase {
  DeleteWalletUseCase(this._repository);

  final ProfileRepository _repository;

  Future<void> execute(int walletId) => _repository.deleteWallet(walletId);
}

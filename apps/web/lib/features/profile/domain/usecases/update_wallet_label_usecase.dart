import 'package:cryprice_frontend/features/profile/domain/entities/wallet.dart';
import 'package:cryprice_frontend/features/profile/domain/repositories/profile_repository.dart';

class UpdateWalletLabelUseCase {
  UpdateWalletLabelUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Wallet> execute({
    required int walletId,
    String? label,
  }) =>
      _repository.updateWalletLabel(walletId: walletId, label: label);
}

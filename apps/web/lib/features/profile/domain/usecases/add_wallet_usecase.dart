import 'package:cryprice_frontend/features/profile/domain/entities/wallet.dart';
import 'package:cryprice_frontend/features/profile/domain/repositories/profile_repository.dart';

class AddWalletUseCase {
  AddWalletUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Wallet> execute({
    required String address,
    String? label,
  }) =>
      _repository.addWallet(address: address, label: label);
}

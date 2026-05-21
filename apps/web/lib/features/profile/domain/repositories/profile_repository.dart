import 'package:cryprice_frontend/features/profile/domain/entities/public_user.dart';
import 'package:cryprice_frontend/features/profile/domain/entities/wallet.dart';
import 'package:cryprice_frontend/features/profile/data/datasources/profile_remote_datasource.dart';

abstract class ProfileRepository {
  Future<PublicUser> getCurrentUser();

  Future<PublicUser> updateProfile(Map<String, Object?> patch);

  Future<List<Wallet>> getWallets();

  Future<Wallet> addWallet({
    required String address,
    String? label,
  });

  Future<Wallet> updateWalletLabel({
    required int walletId,
    String? label,
  });

  Future<void> deleteWallet(int walletId);

  Future<TelegramLinkResponse> createTelegramLink();
}

import 'package:cryprice_frontend/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:cryprice_frontend/features/profile/data/datasources/wallets_remote_datasource.dart';
import 'package:cryprice_frontend/features/profile/domain/entities/public_user.dart';
import 'package:cryprice_frontend/features/profile/domain/entities/wallet.dart';
import 'package:cryprice_frontend/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileRemoteDataSource profileRemote,
    required WalletsRemoteDataSource walletsRemote,
  })  : _profileRemote = profileRemote,
        _walletsRemote = walletsRemote;

  final ProfileRemoteDataSource _profileRemote;
  final WalletsRemoteDataSource _walletsRemote;

  @override
  Future<PublicUser> getCurrentUser() => _profileRemote.getMe();

  @override
  Future<PublicUser> updateProfile(Map<String, Object?> patch) => _profileRemote.updateProfile(patch);

  @override
  Future<List<Wallet>> getWallets() => _walletsRemote.getWallets();

  @override
  Future<Wallet> addWallet({required String address, String? label}) =>
      _walletsRemote.addWallet(address, label);

  @override
  Future<Wallet> updateWalletLabel({required int walletId, String? label}) =>
      _walletsRemote.updateWalletLabel(walletId, label);

  @override
  Future<void> deleteWallet(int walletId) => _walletsRemote.deleteWallet(walletId);

  @override
  Future<TelegramLinkResponse> createTelegramLink() =>
      _profileRemote.createTelegramLink();
}

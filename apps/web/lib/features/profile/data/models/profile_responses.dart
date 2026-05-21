import 'package:cryprice_frontend/features/profile/domain/entities/public_user.dart';
import 'package:cryprice_frontend/features/profile/domain/entities/wallet.dart';

class ProfileResponse {
  const ProfileResponse({required this.user});

  final PublicUser user;

  factory ProfileResponse.fromJson(Map<String, Object?> json) {
    final raw = json['user'];
    if (raw is Map<String, Object?>) {
      return ProfileResponse(user: PublicUser.fromJson(raw));
    }
    if (raw is Map) {
      return ProfileResponse(user: PublicUser.fromJson(raw.cast<String, Object?>()));
    }
    return const ProfileResponse(user: PublicUser());
  }
}

class WalletsResponse {
  const WalletsResponse({required this.wallets});

  final List<Wallet> wallets;

  factory WalletsResponse.fromJson(Map<String, Object?> json) {
    final raw = json['wallets'];
    if (raw is! List) {
      return const WalletsResponse(wallets: <Wallet>[]);
    }
    return WalletsResponse(
      wallets: raw
          .whereType<Map>()
          .map((item) => Wallet.fromJson(item.cast<String, Object?>()))
          .toList(growable: false),
    );
  }
}

class WalletResponse {
  const WalletResponse({required this.wallet});

  final Wallet wallet;

  factory WalletResponse.fromJson(Map<String, Object?> json) {
    final raw = json['wallet'];
    if (raw is Map<String, Object?>) {
      return WalletResponse(wallet: Wallet.fromJson(raw));
    }
    if (raw is Map) {
      return WalletResponse(wallet: Wallet.fromJson(raw.cast<String, Object?>()));
    }
    return const WalletResponse(wallet: Wallet(id: 0, address: ''));
  }
}

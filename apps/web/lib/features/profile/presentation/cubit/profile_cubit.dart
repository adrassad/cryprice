import 'package:cryprice_frontend/core/network/api_error_parser.dart';
import 'package:cryprice_frontend/features/profile/domain/entities/public_user.dart';
import 'package:cryprice_frontend/features/profile/domain/entities/wallet.dart';
import 'package:cryprice_frontend/features/profile/domain/repositories/profile_repository.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/add_wallet_usecase.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/delete_wallet_usecase.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/get_current_user_usecase.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/get_wallets_usecase.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/update_wallet_label_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ProfileViewStatus { initial, loading, loaded, updating, error, unauthenticated }

enum WalletsViewStatus { initial, loading, loaded, empty, adding, updating, deleting, error }

class ProfileState {
  const ProfileState({
    this.profileStatus = ProfileViewStatus.initial,
    this.walletsStatus = WalletsViewStatus.initial,
    this.user,
    this.wallets = const <Wallet>[],
    this.errorMessage,
    this.errorCode,
    this.lastSuccessMessage,
    this.activeWalletId,
    this.telegramLink,
    this.telegramLinkExpiresAt,
  });

  final ProfileViewStatus profileStatus;
  final WalletsViewStatus walletsStatus;
  final PublicUser? user;
  final List<Wallet> wallets;
  final String? errorMessage;
  final String? errorCode;
  final String? lastSuccessMessage;
  final int? activeWalletId;
  final String? telegramLink;
  final String? telegramLinkExpiresAt;

  ProfileState copyWith({
    ProfileViewStatus? profileStatus,
    WalletsViewStatus? walletsStatus,
    PublicUser? user,
    List<Wallet>? wallets,
    String? errorMessage,
    String? errorCode,
    String? lastSuccessMessage,
    int? activeWalletId,
    String? telegramLink,
    String? telegramLinkExpiresAt,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearLink = false,
  }) {
    return ProfileState(
      profileStatus: profileStatus ?? this.profileStatus,
      walletsStatus: walletsStatus ?? this.walletsStatus,
      user: user ?? this.user,
      wallets: wallets ?? this.wallets,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      lastSuccessMessage: clearSuccess ? null : (lastSuccessMessage ?? this.lastSuccessMessage),
      activeWalletId: activeWalletId ?? this.activeWalletId,
      telegramLink: clearLink ? null : (telegramLink ?? this.telegramLink),
      telegramLinkExpiresAt:
          clearLink ? null : (telegramLinkExpiresAt ?? this.telegramLinkExpiresAt),
    );
  }
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required ProfileRepository profileRepository,
    required UpdateProfileUseCase updateProfileUseCase,
    required GetWalletsUseCase getWalletsUseCase,
    required AddWalletUseCase addWalletUseCase,
    required UpdateWalletLabelUseCase updateWalletLabelUseCase,
    required DeleteWalletUseCase deleteWalletUseCase,
  })  : _getCurrentUserUseCase = getCurrentUserUseCase,
        _profileRepository = profileRepository,
        _updateProfileUseCase = updateProfileUseCase,
        _getWalletsUseCase = getWalletsUseCase,
        _addWalletUseCase = addWalletUseCase,
        _updateWalletLabelUseCase = updateWalletLabelUseCase,
        _deleteWalletUseCase = deleteWalletUseCase,
        super(const ProfileState());

  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final ProfileRepository _profileRepository;
  final UpdateProfileUseCase _updateProfileUseCase;
  final GetWalletsUseCase _getWalletsUseCase;
  final AddWalletUseCase _addWalletUseCase;
  final UpdateWalletLabelUseCase _updateWalletLabelUseCase;
  final DeleteWalletUseCase _deleteWalletUseCase;

  Future<void> load() async {
    emit(
      state.copyWith(
        profileStatus: ProfileViewStatus.loading,
        walletsStatus: WalletsViewStatus.loading,
        clearError: true,
        clearSuccess: true,
      ),
    );
    try {
      final user = await _getCurrentUserUseCase.execute();
      final wallets = await _getWalletsUseCase.execute();
      emit(
        state.copyWith(
          profileStatus: ProfileViewStatus.loaded,
          walletsStatus: wallets.isEmpty ? WalletsViewStatus.empty : WalletsViewStatus.loaded,
          user: user,
          wallets: wallets,
          clearError: true,
        ),
      );
    } on Object catch (e) {
      _emitError(e);
    }
  }

  Future<void> refreshAll() => load();

  Future<void> updateProfile(Map<String, Object?> patch) async {
    if (patch.isEmpty) {
      return;
    }
    emit(
      state.copyWith(
        profileStatus: ProfileViewStatus.updating,
        clearError: true,
        clearSuccess: true,
      ),
    );
    try {
      final user = await _updateProfileUseCase.execute(patch);
      emit(
        state.copyWith(
          profileStatus: ProfileViewStatus.loaded,
          user: user,
          lastSuccessMessage: 'Профиль обновлен',
        ),
      );
    } on Object catch (e) {
      _emitError(e);
    }
  }

  /// Keeps legacy [PublicUser.thresholdHf] in sync after alert rule saves.
  ///
  /// Does not emit profile snackbars or [ProfileViewStatus.updating].
  /// Returns `true` when synced or already matching; `false` on API failure.
  Future<bool> syncLegacyThresholdHf(double thresholdHf) async {
    final current = state.user?.thresholdHf;
    if (current != null && (current - thresholdHf).abs() < 0.000001) {
      return true;
    }
    try {
      final user = await _updateProfileUseCase.execute(<String, Object?>{
        'threshold_hf': thresholdHf,
      });
      emit(
        state.copyWith(
          user: user,
          clearError: true,
          clearSuccess: true,
        ),
      );
      return true;
    } on Object {
      return false;
    }
  }

  Future<void> addWallet({
    required String address,
    String? label,
  }) async {
    emit(
      state.copyWith(
        walletsStatus: WalletsViewStatus.adding,
        clearError: true,
        clearSuccess: true,
      ),
    );
    try {
      final wallet = await _addWalletUseCase.execute(address: address, label: label);
      final updated = <Wallet>[wallet, ...state.wallets];
      emit(
        state.copyWith(
          walletsStatus: WalletsViewStatus.loaded,
          wallets: updated,
          lastSuccessMessage: 'Кошелек добавлен',
        ),
      );
    } on Object catch (e) {
      _emitError(e);
    }
  }

  Future<void> updateWalletLabel({
    required int walletId,
    String? label,
  }) async {
    emit(
      state.copyWith(
        walletsStatus: WalletsViewStatus.updating,
        activeWalletId: walletId,
        clearError: true,
        clearSuccess: true,
      ),
    );
    try {
      final wallet = await _updateWalletLabelUseCase.execute(walletId: walletId, label: label);
      final updated = state.wallets
          .map((item) => item.id == walletId ? wallet : item)
          .toList(growable: false);
      emit(
        state.copyWith(
          walletsStatus: updated.isEmpty ? WalletsViewStatus.empty : WalletsViewStatus.loaded,
          wallets: updated,
          activeWalletId: null,
          lastSuccessMessage: 'Метка кошелька обновлена',
        ),
      );
    } on Object catch (e) {
      _emitError(e);
    }
  }

  Future<void> deleteWallet(int walletId) async {
    emit(
      state.copyWith(
        walletsStatus: WalletsViewStatus.deleting,
        activeWalletId: walletId,
        clearError: true,
        clearSuccess: true,
      ),
    );
    try {
      await _deleteWalletUseCase.execute(walletId);
      final updated = state.wallets.where((item) => item.id != walletId).toList(growable: false);
      emit(
        state.copyWith(
          walletsStatus: updated.isEmpty ? WalletsViewStatus.empty : WalletsViewStatus.loaded,
          wallets: updated,
          activeWalletId: null,
          lastSuccessMessage: 'Кошелек удален',
        ),
      );
    } on Object catch (e) {
      _emitError(e);
    }
  }

  Future<void> createTelegramLink() async {
    emit(
      state.copyWith(
        profileStatus: ProfileViewStatus.updating,
        clearError: true,
        clearSuccess: true,
      ),
    );
    try {
      final out = await _profileRepository.createTelegramLink();
      emit(
        state.copyWith(
          profileStatus: ProfileViewStatus.loaded,
          telegramLink: out.telegramDeepLink,
          telegramLinkExpiresAt: out.expiresAt,
          lastSuccessMessage: 'Ссылка для Telegram создана',
        ),
      );
    } on Object catch (e) {
      _emitError(e);
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  void clearTelegramLink() {
    emit(state.copyWith(clearLink: true));
  }

  void _emitError(Object e) {
    final apiError = parseApiError(e);
    if (apiError.statusCode == 401 || apiError.code == 'UNAUTHENTICATED') {
      emit(
        state.copyWith(
          profileStatus: ProfileViewStatus.unauthenticated,
          walletsStatus: WalletsViewStatus.error,
          errorMessage: apiError.message,
          errorCode: apiError.code,
          activeWalletId: null,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        profileStatus: ProfileViewStatus.error,
        walletsStatus: WalletsViewStatus.error,
        errorMessage: apiError.message,
        errorCode: apiError.code,
        activeWalletId: null,
      ),
    );
  }
}

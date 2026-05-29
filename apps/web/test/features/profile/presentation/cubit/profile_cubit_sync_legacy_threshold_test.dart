import 'package:cryprice_frontend/core/network/api_error.dart';
import 'package:cryprice_frontend/features/profile/domain/entities/public_user.dart';
import 'package:cryprice_frontend/features/profile/domain/repositories/profile_repository.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/add_wallet_usecase.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/delete_wallet_usecase.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/get_current_user_usecase.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/get_wallets_usecase.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/update_wallet_label_usecase.dart';
import 'package:cryprice_frontend/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}

class MockGetWalletsUseCase extends Mock implements GetWalletsUseCase {}

class MockAddWalletUseCase extends Mock implements AddWalletUseCase {}

class MockUpdateWalletLabelUseCase extends Mock implements UpdateWalletLabelUseCase {}

class MockDeleteWalletUseCase extends Mock implements DeleteWalletUseCase {}

void main() {
  late MockUpdateProfileUseCase updateProfileUseCase;
  late ProfileCubit cubit;

  setUpAll(() {
    registerFallbackValue(<String, Object?>{});
  });

  setUp(() {
    updateProfileUseCase = MockUpdateProfileUseCase();
    cubit = ProfileCubit(
      getCurrentUserUseCase: MockGetCurrentUserUseCase(),
      profileRepository: MockProfileRepository(),
      updateProfileUseCase: updateProfileUseCase,
      getWalletsUseCase: MockGetWalletsUseCase(),
      addWalletUseCase: MockAddWalletUseCase(),
      updateWalletLabelUseCase: MockUpdateWalletLabelUseCase(),
      deleteWalletUseCase: MockDeleteWalletUseCase(),
    );
    cubit.emit(
      cubit.state.copyWith(
        profileStatus: ProfileViewStatus.loaded,
        user: const PublicUser(id: 1, thresholdHf: 1.25),
      ),
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  test('syncLegacyThresholdHf patches users/me and updates user state', () async {
    when(() => updateProfileUseCase.execute(any())).thenAnswer(
      (_) async => const PublicUser(id: 1, thresholdHf: 1.8),
    );

    final synced = await cubit.syncLegacyThresholdHf(1.8);

    expect(synced, isTrue);
    expect(cubit.state.user?.thresholdHf, 1.8);
    expect(cubit.state.lastSuccessMessage, isNull);
    expect(cubit.state.profileStatus, ProfileViewStatus.loaded);
    final captured = verify(() => updateProfileUseCase.execute(captureAny())).captured.single
        as Map<String, Object?>;
    expect(captured['threshold_hf'], 1.8);
  });

  test('syncLegacyThresholdHf skips PATCH when threshold already matches', () async {
    final synced = await cubit.syncLegacyThresholdHf(1.25);

    expect(synced, isTrue);
    verifyNever(() => updateProfileUseCase.execute(any()));
  });

  test('syncLegacyThresholdHf returns false without mutating profile error state', () async {
    when(() => updateProfileUseCase.execute(any())).thenAnswer((_) async {
      throw const ApiError(
        message: 'Profile unavailable',
        code: 'PROFILE_UNAVAILABLE',
        statusCode: 503,
      );
    });

    final synced = await cubit.syncLegacyThresholdHf(2.0);

    expect(synced, isFalse);
    expect(cubit.state.user?.thresholdHf, 1.25);
    expect(cubit.state.errorMessage, isNull);
    expect(cubit.state.profileStatus, ProfileViewStatus.loaded);
  });
}

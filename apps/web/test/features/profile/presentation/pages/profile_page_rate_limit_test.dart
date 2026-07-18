import 'package:cryprice_frontend/core/network/api_error.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/get_alert_rules_usecase.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/upsert_global_hf_alert_rule_usecase.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alert_rules_cubit.dart';
import 'package:cryprice_frontend/features/auth/domain/entities/auth_user.dart';
import 'package:cryprice_frontend/features/auth/domain/gateways/google_sign_in_gateway.dart';
import 'package:cryprice_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:cryprice_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cryprice_frontend/features/profile/domain/repositories/profile_repository.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/add_wallet_usecase.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/delete_wallet_usecase.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/get_current_user_usecase.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/get_wallets_usecase.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:cryprice_frontend/features/profile/domain/usecases/update_wallet_label_usecase.dart';
import 'package:cryprice_frontend/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:cryprice_frontend/features/profile/presentation/pages/profile_page.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockGoogleSignInGateway extends Mock implements GoogleSignInGateway {}

class MockGetAlertRulesUseCase extends Mock implements GetAlertRulesUseCase {}

class MockUpsertGlobalHfAlertRuleUseCase extends Mock
    implements UpsertGlobalHfAlertRuleUseCase {}

void main() {
  late AuthCubit authCubit;
  late ProfileCubit profileCubit;
  late AlertRulesCubit alertRulesCubit;
  late MockProfileRepository repository;

  setUp(() {
    repository = MockProfileRepository();
    profileCubit = ProfileCubit(
      getCurrentUserUseCase: GetCurrentUserUseCase(repository),
      profileRepository: repository,
      updateProfileUseCase: UpdateProfileUseCase(repository),
      getWalletsUseCase: GetWalletsUseCase(repository),
      addWalletUseCase: AddWalletUseCase(repository),
      updateWalletLabelUseCase: UpdateWalletLabelUseCase(repository),
      deleteWalletUseCase: DeleteWalletUseCase(repository),
    );
    alertRulesCubit = AlertRulesCubit(
      getAlertRulesUseCase: MockGetAlertRulesUseCase(),
      upsertGlobalHfAlertRuleUseCase: MockUpsertGlobalHfAlertRuleUseCase(),
    );
    authCubit = AuthCubit(MockAuthRepository(), MockGoogleSignInGateway());
    authCubit.emit(AuthStateAuthenticated(const AuthUser(email: 'user@test.dev')));
  });

  tearDown(() async {
    await authCubit.close();
    await profileCubit.close();
    await alertRulesCubit.close();
  });

  testWidgets('authenticated profile shows rate-limit message on 429', (tester) async {
    when(() => repository.getCurrentUser()).thenThrow(
      const ApiError(
        message: 'Too many requests, please try again later.',
        code: kApiErrorCodeRateLimited,
        statusCode: 429,
      ),
    );

    await tester.pumpWidget(_app(authCubit, profileCubit, alertRulesCubit, locale: 'ru'));
    await tester.pumpAndSettle();

    expect(
      find.text('Слишком много запросов. Подождите немного и попробуйте снова.'),
      findsOneWidget,
    );
    expect(find.text('Не удалось загрузить профиль'), findsNothing);
    verifyNever(() => repository.getWallets());
  });
}

Widget _app(
  AuthCubit authCubit,
  ProfileCubit profileCubit,
  AlertRulesCubit alertRulesCubit, {
  required String locale,
}) {
  return MaterialApp(
    locale: Locale(locale),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<ProfileCubit>.value(value: profileCubit),
        BlocProvider<AlertRulesCubit>.value(value: alertRulesCubit),
      ],
      child: const ProfilePage(),
    ),
  );
}

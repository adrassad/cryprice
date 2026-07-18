import 'package:cryprice_frontend/features/alerts/domain/usecases/get_alert_rules_usecase.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/upsert_global_hf_alert_rule_usecase.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alert_rules_cubit.dart';
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
    authCubit.emit(const AuthStateUnauthenticated());
  });

  tearDown(() async {
    await authCubit.close();
    await profileCubit.close();
    await alertRulesCubit.close();
  });

  testWidgets('guest profile shows localized account access panel', (tester) async {
    await tester.pumpWidget(_app(authCubit, profileCubit, alertRulesCubit));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('account_access_required_panel')), findsOneWidget);
    expect(find.text('Account access required'), findsOneWidget);
    expect(find.text('No wallet connection'), findsOneWidget);
    expect(find.text('Public addresses for monitoring only'), findsOneWidget);
    expect(find.textContaining('Кошел'), findsNothing);
    expect(find.textContaining('Требуется авторизация'), findsNothing);

    verifyNever(() => repository.getCurrentUser());
    verifyNever(() => repository.getWallets());
  });
}

Widget _app(
  AuthCubit authCubit,
  ProfileCubit profileCubit,
  AlertRulesCubit alertRulesCubit,
) {
  return MaterialApp(
    locale: const Locale('en'),
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

import 'package:cryprice_frontend/core/auth/auth_flow_guard.dart';
import 'package:cryprice_frontend/core/web/app_update_listener.dart';
import 'package:cryprice_frontend/core/web/app_version_info.dart';
import 'package:cryprice_frontend/core/web/app_version_service.dart';
import 'package:cryprice_frontend/features/auth/domain/entities/auth_user.dart';
import 'package:cryprice_frontend/features/auth/domain/gateways/google_sign_in_gateway.dart';
import 'package:cryprice_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:cryprice_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockGoogleSignInGateway extends Mock implements GoogleSignInGateway {}

void main() {
  late MockAuthRepository repository;
  late MockGoogleSignInGateway google;

  setUpAll(() {
    registerFallbackValue(const AuthUser(email: 'fallback@test.dev'));
  });

  setUp(() {
    repository = MockAuthRepository();
    google = MockGoogleSignInGateway();
    clearAuthFlowGuardForTesting();
    resetAppVersionServiceForTesting();
    AppUpdateListener.debugForceUpdateChecks = false;
  });

  tearDown(() {
    AppUpdateListener.debugForceUpdateChecks = false;
  });

  Widget buildHarness(AuthCubit authCubit) {
    return MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: const AppUpdateListener(
          child: Scaffold(
            body: SizedBox(),
          ),
        ),
      ),
    );
  }

  testWidgets('gis_error=cancelled shows auth recovery banner', (tester) async {
    final authCubit = AuthCubit(repository, google);
    addTearDown(authCubit.close);

    await tester.pumpWidget(buildHarness(authCubit));
    authCubit.emit(
      const AuthStateUnauthenticated(
        errorMessage: 'cancelled',
        suggestAuthReload: true,
      ),
    );
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.textContaining('CryPrice auth flow was updated'),
      findsOneWidget,
    );
    expect(find.text('Reload app'), findsOneWidget);
  });

  testWidgets('newer deploy version shows update banner', (tester) async {
    AppUpdateListener.debugForceUpdateChecks = true;
    debugSetRemoteAppVersionForTesting(
      const AppVersionInfo(
        app: 'cryprice-web',
        build: 'deploy-2',
        authFlowVersion: 2,
      ),
    );

    final authCubit = AuthCubit(repository, google);
    addTearDown(authCubit.close);
    authCubit.emit(const AuthStateUnauthenticated());

    await tester.pumpWidget(buildHarness(authCubit));
    await tester.pump();
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.textContaining('CryPrice was updated'),
      findsOneWidget,
    );
    expect(find.text('Reload app'), findsOneWidget);
  });
}

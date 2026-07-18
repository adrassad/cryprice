import 'package:bloc_test/bloc_test.dart';
import 'package:cryprice_frontend/core/auth/auth_flow_guard.dart';
import 'package:cryprice_frontend/core/config/auth_backend_config.dart';
import 'package:cryprice_frontend/core/config/google_auth_redirect_urls.dart';
import 'package:cryprice_frontend/core/config/google_auth_return_to.dart';
import 'package:cryprice_frontend/core/web/google_auth_browser_policy.dart';
import 'package:cryprice_frontend/features/auth/data/datasources/google_auth_oauth_start.dart';
import 'package:cryprice_frontend/features/auth/data/datasources/google_auth_redirect_completion.dart';
import 'package:cryprice_frontend/features/auth/domain/entities/auth_user.dart';
import 'package:cryprice_frontend/features/auth/domain/gateways/google_sign_in_gateway.dart';
import 'package:cryprice_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:cryprice_frontend/features/auth/presentation/auth_error_messages.dart';
import 'package:cryprice_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockGoogleSignInGateway extends Mock implements GoogleSignInGateway {}

void main() {
  late MockAuthRepository repository;
  late MockGoogleSignInGateway google;

  const productionReturnTo = 'https://app.cryprice.dev';
  const expectedStartUrl =
      'https://api.cryprice.dev/auth/google/oauth/start'
      '?return_to=https%3A%2F%2Fapp.cryprice.dev';

  setUpAll(() {
    registerFallbackValue(const AuthUser(email: 'fallback@test.dev'));
    registerFallbackValue('');
  });

  setUp(() {
    repository = MockAuthRepository();
    google = MockGoogleSignInGateway();
    clearAuthFlowGuardForTesting();
    clearGoogleAuthRedirectQueryParams();
    debugSetGoogleAuthReturnToForTesting(null);
    resetGoogleOAuthSignInTestHooks();
    debugSetGoogleAuthUxMode(null);
    AuthCubit.debugAllowRedirectOnNonWeb = false;
  });

  Future<void> expectWebOAuthStart(String browserLabel) async {
    AuthCubit.debugAllowRedirectOnNonWeb = true;
    final cubit = AuthCubit(repository, google);
    addTearDown(cubit.close);
    cubit.emit(const AuthStateUnauthenticated());

    await cubit.signInWithGoogle();

    expect(
      debugLastGoogleOAuthStartUrl,
      expectedStartUrl,
      reason: '$browserLabel must use unified OAuth start endpoint',
    );
    expect(debugLastGoogleOAuthStartUrl, isNot(contains('/auth/google/redirect/start')));
    verifyNever(() => google.getIdToken());
    verifyNever(() => repository.signInWithGoogleIdToken(any()));
    verifyNever(() => repository.prepareGoogleRedirectStart(any()));
  }

  for (final browser in <String>['Chrome', 'Safari', 'iOS', 'PWA']) {
    test('$browser Web login uses /auth/google/oauth/start', () async {
      await expectWebOAuthStart(browser);
    });
  }

  test('legacy popup browser policy does not change Web OAuth endpoint', () async {
    debugSetGoogleAuthUxMode(GoogleAuthUxMode.popup);
    await expectWebOAuthStart('Chrome-with-popup-override');
  });

  test('canonical builder matches production OAuth start URL', () {
    expect(
      buildGoogleOAuthStartUrl(
        apiBaseUrl: authBackendBaseUrl,
        returnTo: productionReturnTo,
      ),
      expectedStartUrl,
    );
  });

  blocTest<AuthCubit, AuthState>(
    'gis_exchange triggers POST /auth/google/exchange and authenticated state',
    build: () {
      debugSetGoogleAuthExchangeCodeForTesting('exchange-code');
      when(() => repository.exchangeGoogleRedirectCode('exchange-code')).thenAnswer(
        (_) async => const AuthUser(email: 'user@test.dev'),
      );
      when(() => repository.restoreSession()).thenAnswer(
        (_) async => AuthRestoreAuthenticated(const AuthUser(email: 'user@test.dev')),
      );
      return AuthCubit(repository, google);
    },
    seed: () => const AuthStateUnauthenticated(),
    act: (cubit) => cubit.completePendingGoogleRedirect(),
    expect: () => [
      isA<AuthStateLoading>(),
      isA<AuthStateAuthenticated>(),
    ],
    verify: (cubit) {
      verify(() => repository.exchangeGoogleRedirectCode('exchange-code')).called(1);
      verify(() => repository.restoreSession()).called(1);
      verifyNever(() => repository.signInWithGoogleIdToken(any()));
      expect(cubit.sessionEpoch, 1);
    },
  );

  blocTest<AuthCubit, AuthState>(
    'gis_error remains guest with friendly error code',
    build: () {
      debugSetGoogleAuthRedirectErrorForTesting('cancelled');
      return AuthCubit(repository, google);
    },
    seed: () => const AuthStateUnauthenticated(),
    act: (cubit) => cubit.completePendingGoogleRedirect(),
    verify: (cubit) {
      verifyNever(() => repository.exchangeGoogleRedirectCode(any()));
      final state = cubit.state as AuthStateUnauthenticated;
      expect(state.errorMessage, kGoogleAuthRedirectFailedErrorCode);
    },
  );

  blocTest<AuthCubit, AuthState>(
    'logout still works after Web OAuth architecture',
    build: () {
      when(() => repository.logout(pushToken: any(named: 'pushToken'))).thenAnswer((_) async {});
      final cubit = AuthCubit(repository, google);
      cubit.emit(AuthStateAuthenticated(const AuthUser(email: 'a@test.dev')));
      return cubit;
    },
    act: (cubit) => cubit.signOut(),
    expect: () => [
      isA<AuthStateLoading>(),
      isA<AuthStateUnauthenticated>(),
    ],
    verify: (cubit) {
      verify(() => repository.logout(pushToken: any(named: 'pushToken'))).called(1);
      expect(cubit.sessionEpoch, 1);
    },
  );
}

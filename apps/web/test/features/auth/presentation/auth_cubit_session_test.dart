import 'package:bloc_test/bloc_test.dart';
import 'package:cryprice_frontend/core/auth/auth_flow_guard.dart';
import 'package:cryprice_frontend/core/config/google_auth_return_to.dart';
import 'package:cryprice_frontend/features/auth/data/datasources/google_auth_oauth_start.dart';
import 'package:cryprice_frontend/features/auth/domain/entities/auth_user.dart';
import 'package:cryprice_frontend/features/auth/domain/gateways/google_sign_in_gateway.dart';
import 'package:cryprice_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:cryprice_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockGoogleSignInGateway extends Mock implements GoogleSignInGateway {}

void main() {
  late MockAuthRepository repository;
  late MockGoogleSignInGateway google;

  setUpAll(() {
    registerFallbackValue(const AuthUser(email: 'fallback@test.dev'));
    registerFallbackValue('');
  });

  setUp(() {
    repository = MockAuthRepository();
    google = MockGoogleSignInGateway();
    clearAuthFlowGuardForTesting();
    debugSetGoogleAuthReturnToForTesting(null);
    resetGoogleOAuthSignInTestHooks();
    AuthCubit.debugAllowRedirectOnNonWeb = false;
  });

  test('sessionEpoch starts at zero', () {
    final cubit = AuthCubit(repository, google);
    expect(cubit.sessionEpoch, 0);
    cubit.close();
  });

  blocTest<AuthCubit, AuthState>(
    'signOut increments sessionEpoch and clears auth state',
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
      expect(cubit.sessionEpoch, 1);
      verify(() => repository.logout(pushToken: any(named: 'pushToken'))).called(1);
    },
  );

  blocTest<AuthCubit, AuthState>(
    'successful Google sign-in increments sessionEpoch',
    build: () {
      when(() => google.getIdToken()).thenAnswer((_) async => 'id-token');
      when(() => repository.signInWithGoogleIdToken('id-token')).thenAnswer(
        (_) async => const AuthUser(email: 'user@test.dev'),
      );
      when(() => repository.restoreSession()).thenAnswer(
        (_) async => AuthRestoreAuthenticated(const AuthUser(email: 'user@test.dev')),
      );
      final cubit = AuthCubit(repository, google);
      cubit.emit(const AuthStateUnauthenticated());
      return cubit;
    },
    act: (cubit) => cubit.signInWithGoogle(),
    expect: () => [
      isA<AuthStateLoading>(),
      isA<AuthStateAuthenticated>(),
    ],
    verify: (cubit) {
      expect(cubit.sessionEpoch, 1);
      expect(isAuthFlowInProgress(), isFalse);
      verify(() => repository.restoreSession()).called(1);
    },
  );

  blocTest<AuthCubit, AuthState>(
    'Google sign-in cancel clears auth-flow guard and stays guest',
    build: () {
      when(() => google.getIdToken()).thenAnswer((_) async => null);
      final cubit = AuthCubit(repository, google);
      cubit.emit(const AuthStateUnauthenticated());
      return cubit;
    },
    act: (cubit) => cubit.signInWithGoogle(),
    expect: () => [
      isA<AuthStateLoading>(),
      isA<AuthStateUnauthenticated>(),
    ],
    verify: (_) {
      expect(isAuthFlowInProgress(), isFalse);
      verifyNever(() => repository.signInWithGoogleIdToken(any()));
    },
  );

  blocTest<AuthCubit, AuthState>(
    'Google sign-in error clears auth-flow guard',
    build: () {
      when(() => google.getIdToken()).thenAnswer((_) async => 'id-token');
      when(() => repository.signInWithGoogleIdToken('id-token'))
          .thenThrow(Exception('network'));
      final cubit = AuthCubit(repository, google);
      cubit.emit(const AuthStateUnauthenticated());
      return cubit;
    },
    act: (cubit) => cubit.signInWithGoogle(),
    expect: () => [
      isA<AuthStateLoading>(),
      isA<AuthStateUnauthenticated>(),
    ],
    verify: (_) {
      expect(isAuthFlowInProgress(), isFalse);
    },
  );

  blocTest<AuthCubit, AuthState>(
    'Web OAuth mode navigates to backend oauth start without popup',
    build: () {
      AuthCubit.debugAllowRedirectOnNonWeb = true;
      final cubit = AuthCubit(repository, google);
      cubit.emit(const AuthStateUnauthenticated());
      return cubit;
    },
    seed: () => const AuthStateUnauthenticated(),
    act: (cubit) => cubit.signInWithGoogle(),
    expect: () => <AuthState>[],
    verify: (_) {
      verifyNever(() => google.getIdToken());
      verifyNever(() => repository.signInWithGoogleIdToken(any()));
      verifyNever(() => repository.prepareGoogleRedirectStart(any()));
      expect(debugStartGoogleOAuthSignInCalls, 1);
      expect(
        debugLastGoogleOAuthStartUrl,
        'https://api.cryprice.dev/auth/google/oauth/start'
        '?return_to=https%3A%2F%2Fapp.cryprice.dev',
      );
    },
  );

  blocTest<AuthCubit, AuthState>(
    'Web OAuth start URL encodes return_to',
    build: () {
      AuthCubit.debugAllowRedirectOnNonWeb = true;
      debugSetGoogleAuthReturnToForTesting('https://app.cryprice.dev/portfolio');
      final cubit = AuthCubit(repository, google);
      cubit.emit(const AuthStateUnauthenticated());
      return cubit;
    },
    seed: () => const AuthStateUnauthenticated(),
    act: (cubit) => cubit.signInWithGoogle(),
    expect: () => <AuthState>[],
    verify: (_) {
      expect(
        debugLastGoogleOAuthStartUrl,
        contains('return_to=https%3A%2F%2Fapp.cryprice.dev%2Fportfolio'),
      );
    },
  );
}

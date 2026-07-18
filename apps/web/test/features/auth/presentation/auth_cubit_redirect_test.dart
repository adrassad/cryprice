import 'package:bloc_test/bloc_test.dart';
import 'package:cryprice_frontend/core/auth/auth_flow_guard.dart';
import 'package:cryprice_frontend/features/auth/data/datasources/google_auth_redirect_completion.dart';
import 'package:cryprice_frontend/features/auth/presentation/auth_error_messages.dart';
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
  });

  setUp(() {
    repository = MockAuthRepository();
    google = MockGoogleSignInGateway();
    clearAuthFlowGuardForTesting();
    clearGoogleAuthRedirectQueryParams();
  });

  blocTest<AuthCubit, AuthState>(
    'redirect exchange restores session and emits authenticated state',
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
      expect(cubit.sessionEpoch, 1);
      expect(isAuthFlowInProgress(), isFalse);
      verify(() => repository.exchangeGoogleRedirectCode('exchange-code')).called(1);
      verify(() => repository.restoreSession()).called(1);
    },
  );

  blocTest<AuthCubit, AuthState>(
    'redirect error returns guest mode with friendly error code',
    build: () {
      debugSetGoogleAuthRedirectErrorForTesting('cancelled');
      return AuthCubit(repository, google);
    },
    seed: () => const AuthStateUnauthenticated(),
    act: (cubit) => cubit.completePendingGoogleRedirect(),
    expect: () => [
      isA<AuthStateUnauthenticated>(),
    ],
    verify: (cubit) {
      verifyNever(() => repository.exchangeGoogleRedirectCode(any()));
      final state = cubit.state as AuthStateUnauthenticated;
      expect(state.errorMessage, kGoogleAuthRedirectFailedErrorCode);
    },
  );

  blocTest<AuthCubit, AuthState>(
    'unknown redirect error uses same friendly error code',
    build: () {
      debugSetGoogleAuthRedirectErrorForTesting('access_denied');
      return AuthCubit(repository, google);
    },
    seed: () => const AuthStateUnauthenticated(),
    act: (cubit) => cubit.completePendingGoogleRedirect(),
    verify: (cubit) {
      final state = cubit.state as AuthStateUnauthenticated;
      expect(state.errorMessage, kGoogleAuthRedirectFailedErrorCode);
    },
  );

  blocTest<AuthCubit, AuthState>(
    'redirect exchange failure stays unauthenticated and clears params',
    build: () {
      debugSetGoogleAuthExchangeCodeForTesting('bad-code');
      when(() => repository.exchangeGoogleRedirectCode('bad-code'))
          .thenThrow(Exception('exchange failed'));
      return AuthCubit(repository, google);
    },
    seed: () => const AuthStateUnauthenticated(),
    act: (cubit) => cubit.completePendingGoogleRedirect(),
    expect: () => [
      isA<AuthStateLoading>(),
      isA<AuthStateUnauthenticated>(),
    ],
    verify: (_) {
      verify(() => repository.exchangeGoogleRedirectCode('bad-code')).called(1);
      verifyNever(() => repository.restoreSession());
    },
  );

  blocTest<AuthCubit, AuthState>(
    'redirect cancelled suggests auth stale recovery reload',
    build: () {
      debugSetGoogleAuthRedirectErrorForTesting('cancelled');
      return AuthCubit(repository, google);
    },
    seed: () => const AuthStateUnauthenticated(),
    act: (cubit) => cubit.completePendingGoogleRedirect(),
    verify: (cubit) {
      final state = cubit.state;
      expect(state, isA<AuthStateUnauthenticated>());
      expect((state as AuthStateUnauthenticated).suggestAuthReload, isTrue);
    },
  );
}

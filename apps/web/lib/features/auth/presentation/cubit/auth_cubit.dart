import 'dart:async' show unawaited;

import 'package:cryprice_frontend/core/auth/auth_flow_guard.dart';
import 'package:cryprice_frontend/core/config/google_auth_return_to.dart';
import 'package:cryprice_frontend/core/web/app_update_coordinator.dart';
import 'package:cryprice_frontend/core/web/auth_stale_recovery.dart';
import 'package:cryprice_frontend/features/auth/data/datasources/google_auth_oauth_start.dart';
import 'package:cryprice_frontend/features/auth/presentation/auth_error_messages.dart';
import 'package:cryprice_frontend/features/auth/data/datasources/google_auth_redirect_completion.dart';
import 'package:cryprice_frontend/features/auth/domain/entities/auth_user.dart';
import 'package:cryprice_frontend/features/auth/domain/exceptions/auth_api_exception.dart';
import 'package:cryprice_frontend/features/auth/domain/gateways/google_sign_in_gateway.dart';
import 'package:cryprice_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:cryprice_frontend/features/push_notifications/presentation/push_notification_coordinator.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class AuthState {
  const AuthState();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated({
    this.errorMessage,
    this.suggestAuthReload = false,
  });
  final String? errorMessage;

  /// True when a stale web bundle likely caused the auth failure.
  final bool suggestAuthReload;
}

class AuthStateAuthenticated extends AuthState {
  AuthStateAuthenticated(this.user) : super();
  final AuthUser user;
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._repository,
    this._google, {
    PushNotificationCoordinator? pushCoordinator,
  })  : _pushCoordinator = pushCoordinator,
        super(AuthStateLoading());

  /// Tests only: allow redirect branch without [kIsWeb].
  static bool debugAllowRedirectOnNonWeb = false;

  final AuthRepository _repository;
  final GoogleSignInGateway _google;
  final PushNotificationCoordinator? _pushCoordinator;
  int _requestGen = 0;
  int _sessionEpoch = 0;

  /// Bumped on logout and successful login so [AppShell] remounts with fresh cubits.
  int get sessionEpoch => _sessionEpoch;

  bool _isStale(int requestId) => requestId != _requestGen;

  void _emitAuthenticated(AuthUser user) {
    _sessionEpoch++;
    emit(AuthStateAuthenticated(user));
    _notifyPushAuthenticated();
  }

  void _notifyPushAuthenticated() {
    final coordinator = _pushCoordinator;
    if (coordinator == null) {
      return;
    }
    unawaited(coordinator.onAuthenticated());
  }

  Future<void> _unregisterPushBeforeLogout() async {
    final coordinator = _pushCoordinator;
    if (coordinator == null) {
      return;
    }
    await coordinator.onLogout();
  }

  Future<String?> _readPushTokenForLogout() async {
    final coordinator = _pushCoordinator;
    if (coordinator == null) {
      return null;
    }
    return coordinator.readCachedTokenForLogout();
  }

  /// Completes GIS redirect return (`?gis_exchange=`) before normal session restore.
  ///
  /// Returns true when authenticated state was emitted from the redirect exchange.
  Future<bool> completePendingGoogleRedirect() async {
    final redirectError = readGoogleAuthRedirectError();
    final code = readGoogleAuthExchangeCode();
    if (!kIsWeb && redirectError == null && (code == null || code.isEmpty)) {
      return false;
    }

    if (redirectError != null) {
      clearGoogleAuthRedirectQueryParams();
      emit(
        AuthStateUnauthenticated(
          errorMessage: kGoogleAuthRedirectFailedErrorCode,
          suggestAuthReload: shouldSuggestAuthStaleRecovery(
            redirectError: redirectError,
            exchangeCode: code,
            exchangeAttempted: false,
            authenticated: false,
          ),
        ),
      );
      endAuthFlow();
      await onAuthFlowEndedForAppUpdate();
      return false;
    }

    if (code == null || code.isEmpty) {
      return false;
    }

    final requestId = ++_requestGen;
    beginAuthFlow();
    emit(const AuthStateLoading());
    var exchangeAttempted = false;
    try {
      if (kDebugMode) {
        debugPrint('[Auth][Web] redirect exchange started');
      }
      exchangeAttempted = true;
      await _repository.exchangeGoogleRedirectCode(code);
      if (_isStale(requestId)) {
        return false;
      }
      final restored = await _repository.restoreSession();
      if (_isStale(requestId)) {
        return false;
      }
      if (restored is AuthRestoreAuthenticated) {
        _emitAuthenticated(restored.user);
        return true;
      }
      if (!_isStale(requestId)) {
        emit(
          AuthStateUnauthenticated(
            errorMessage: 'Auth failed',
            suggestAuthReload: shouldSuggestAuthStaleRecovery(
              exchangeCode: code,
              exchangeAttempted: exchangeAttempted,
              authenticated: false,
              authErrorMessage: 'Auth failed',
            ),
          ),
        );
      }
      return false;
    } on AuthApiException catch (e) {
      if (!_isStale(requestId)) {
        emit(
          AuthStateUnauthenticated(
            errorMessage: e.message,
            suggestAuthReload: shouldSuggestAuthStaleRecovery(
              exchangeCode: code,
              exchangeAttempted: exchangeAttempted,
              authenticated: false,
              authErrorMessage: e.message,
            ),
          ),
        );
      }
      return false;
    } on Object {
      if (!_isStale(requestId)) {
        emit(
          AuthStateUnauthenticated(
            errorMessage: 'Auth failed',
            suggestAuthReload: shouldSuggestAuthStaleRecovery(
              exchangeCode: code,
              exchangeAttempted: exchangeAttempted,
              authenticated: false,
              authErrorMessage: 'Auth failed',
            ),
          ),
        );
      }
      return false;
    } finally {
      clearGoogleAuthRedirectQueryParams();
      endAuthFlow();
      await onAuthFlowEndedForAppUpdate();
    }
  }

  /// [GET /auth/me] and [POST /auth/refresh] with stored tokens.
  Future<void> restore() async {
    final requestId = ++_requestGen;
    final prev = state;
    emit(AuthStateLoading());
    try {
      final r = await _repository.restoreSession();
      if (_isStale(requestId)) {
        return;
      }
      if (r is AuthRestoreAuthenticated) {
        _emitAuthenticated(r.user);
      } else if (r is AuthRestoreDeferred) {
        if (prev is AuthStateAuthenticated) {
          emit(prev);
        } else {
          emit(AuthStateUnauthenticated(errorMessage: r.reason));
        }
      } else {
        emit(const AuthStateUnauthenticated());
      }
    } on Object {
      if (_isStale(requestId)) {
        return;
      }
      if (prev is AuthStateAuthenticated) {
        emit(prev);
      } else {
        emit(const AuthStateUnauthenticated());
      }
    }
  }

  /// Web: backend OAuth redirect. Native mobile: Google ID token → [POST /auth/google].
  Future<void> signInWithGoogle() async {
    if (kIsWeb || debugAllowRedirectOnNonWeb) {
      await _signInWithGoogleOAuth();
      return;
    }
    await _signInWithGooglePopup();
  }

  Future<void> _signInWithGoogleOAuth() async {
    final requestId = ++_requestGen;
    beginAuthFlow();
    try {
      final returnTo = resolveGoogleAuthReturnTo();
      if (kDebugMode) {
        debugPrint('[Auth][Web] OAuth sign-in started return_to=$returnTo');
      }
      await startGoogleOAuthSignIn(returnTo);
      // Page navigates away; completion runs in [completePendingGoogleRedirect].
    } on Object {
      if (!_isStale(requestId)) {
        emit(const AuthStateUnauthenticated(errorMessage: 'Auth failed'));
      }
      endAuthFlow();
      await onAuthFlowEndedForAppUpdate();
    }
  }

  /// Legacy GIS popup / [POST /auth/google] path for native mobile only.
  Future<void> _signInWithGooglePopup() async {
    final requestId = ++_requestGen;
    beginAuthFlow();
    try {
      if (kIsWeb) {
        if (kDebugMode) {
          debugPrint('[Auth][Web] popup sign-in started');
        }
      } else {
        emit(AuthStateLoading());
      }
      final String? idToken = await _google.getIdToken();
      if (_isStale(requestId)) {
        return;
      }
      if (kDebugMode) {
        debugPrint(
          kIsWeb
              ? '[Auth][Web] idToken: ${idToken == null || idToken.isEmpty ? "null" : "received"}'
              : '[Auth] idToken: ${idToken == null || idToken.isEmpty ? "null" : "received"}',
        );
      }
      if (idToken == null || idToken.isEmpty) {
        emit(const AuthStateUnauthenticated(errorMessage: null));
        return;
      }
      if (kIsWeb) {
        emit(const AuthStateLoading());
      }
      if (kDebugMode) {
        debugPrint(kIsWeb ? '[Auth][Web] backend auth started' : '[Auth] backend auth started');
      }
      await _repository.signInWithGoogleIdToken(idToken);
      if (_isStale(requestId)) {
        return;
      }
      final restored = await _repository.restoreSession();
      if (_isStale(requestId)) {
        return;
      }
      if (restored is AuthRestoreAuthenticated) {
        _emitAuthenticated(restored.user);
        return;
      }
      emit(const AuthStateUnauthenticated(errorMessage: 'Auth failed'));
    } on AuthApiException catch (e) {
      if (_isStale(requestId)) {
        return;
      }
      emit(AuthStateUnauthenticated(errorMessage: e.message));
    } on Object {
      if (_isStale(requestId)) {
        return;
      }
      emit(const AuthStateUnauthenticated(errorMessage: 'Auth failed'));
    } finally {
      endAuthFlow();
      await onAuthFlowEndedForAppUpdate();
    }
  }

  /// [POST /auth/logout] + clear storage + Google sign out.
  Future<void> signOut() async {
    final requestId = ++_requestGen;
    emit(AuthStateLoading());
    try {
      final pushToken = await _readPushTokenForLogout();
      await _unregisterPushBeforeLogout();
      await _repository.logout(pushToken: pushToken);
    } on Object {
      // [logout] clears locally even if remote fails
    } finally {
      endAuthFlow();
    }
    if (_isStale(requestId)) {
      return;
    }
    _sessionEpoch++;
    emit(const AuthStateUnauthenticated());
  }
}

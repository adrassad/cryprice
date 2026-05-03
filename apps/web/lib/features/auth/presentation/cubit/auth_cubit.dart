import 'package:crypto_tracker_app/features/auth/domain/entities/auth_user.dart';
import 'package:crypto_tracker_app/features/auth/domain/exceptions/auth_api_exception.dart';
import 'package:crypto_tracker_app/features/auth/domain/gateways/google_sign_in_gateway.dart';
import 'package:crypto_tracker_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class AuthState {
  const AuthState();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated({this.errorMessage});
  final String? errorMessage;
}

class AuthStateAuthenticated extends AuthState {
  AuthStateAuthenticated(this.user) : super();
  final AuthUser user;
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository, this._google) : super(AuthStateLoading());

  final AuthRepository _repository;
  final GoogleSignInGateway _google;
  int _requestGen = 0;

  bool _isStale(int requestId) => requestId != _requestGen;

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
        emit(AuthStateAuthenticated(r.user));
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

  /// Google sign-in UI → ID token → [POST /auth/google].
  Future<void> signInWithGoogle() async {
    final requestId = ++_requestGen;
    if (kIsWeb) {
      if (kDebugMode) {
        debugPrint('[Auth][Web] web sign-in started');
      }
    } else {
      emit(AuthStateLoading());
    }
    try {
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
      final AuthUser user = await _repository.signInWithGoogleIdToken(idToken);
      if (_isStale(requestId)) {
        return;
      }
      emit(AuthStateAuthenticated(user));
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
    }
  }

  /// [POST /auth/logout] + clear storage + Google sign out.
  Future<void> signOut() async {
    final requestId = ++_requestGen;
    emit(AuthStateLoading());
    try {
      await _repository.logout();
    } on Object {
      // [logout] clears locally even if remote fails
    }
    if (_isStale(requestId)) {
      return;
    }
    emit(const AuthStateUnauthenticated());
  }
}

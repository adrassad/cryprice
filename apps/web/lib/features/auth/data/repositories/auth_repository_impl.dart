import 'package:crypto_tracker_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:crypto_tracker_app/features/auth/data/local/auth_token_store.dart';
import 'package:crypto_tracker_app/features/auth/domain/entities/auth_user.dart';
import 'package:crypto_tracker_app/features/auth/domain/exceptions/auth_api_exception.dart';
import 'package:crypto_tracker_app/features/auth/domain/gateways/google_sign_in_gateway.dart';
import 'package:crypto_tracker_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLegacySignedIn = 'auth_session_signed_in';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthRemoteDataSource remote, required AuthTokenStore store, required GoogleSignInGateway google})
    : _remote = remote,
      _store = store,
      _google = google;

  final AuthRemoteDataSource _remote;
  final AuthTokenStore _store;
  final GoogleSignInGateway _google;

  @override
  Future<AuthRestoreResult> restoreSession() async {
    await _clearLegacyLocalFlag();
    final st = await _store.read();
    if ((st.access == null || st.access!.isEmpty) && (st.refresh == null || st.refresh!.isEmpty)) {
      return AuthRestoreUnauthenticated();
    }
    if (st.access != null && st.access!.isNotEmpty) {
      try {
        final user = await _remote.getMe(st.access!);
        return AuthRestoreAuthenticated(user);
      } on AuthApiException catch (e) {
        if (e.statusCode == 401) {
          // fall through to refresh with [st.refresh]
        } else if (e.statusCode == 403) {
          await _store.clear();
          return AuthRestoreUnauthenticated();
        } else {
          return AuthRestoreDeferred(e.message);
        }
      } on Object {
        return AuthRestoreDeferred();
      }
    }
    if (st.refresh == null || st.refresh!.isEmpty) {
      await _store.clear();
      return AuthRestoreUnauthenticated();
    }
    try {
      final bundle = await _remote.postRefresh(st.refresh!);
      await _store.write(
        access: bundle.accessToken,
        refresh: bundle.refreshToken,
        refreshExpiresAt: bundle.refreshExpiresAt,
      );
      return AuthRestoreAuthenticated(bundle.user);
    } on AuthApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        await _store.clear();
        return AuthRestoreUnauthenticated();
      }
      return AuthRestoreDeferred(e.message);
    } on Object {
      return AuthRestoreDeferred();
    }
  }

  @override
  Future<AuthUser> signInWithGoogleIdToken(String idToken) async {
    final bundle = await _remote.postAuthGoogle(idToken);
    await _store.write(
      access: bundle.accessToken,
      refresh: bundle.refreshToken,
      refreshExpiresAt: bundle.refreshExpiresAt,
    );
    return bundle.user;
  }

  @override
  Future<void> logout() async {
    final st = await _store.read();
    if (st.refresh != null && st.refresh!.isNotEmpty) {
      try {
        await _remote.postLogout(st.refresh!);
      } on Object {
        // still clear local session
      }
    }
    await _store.clear();
    try {
      await _google.signOut();
    } on Object {
      // ignore
    }
  }

  /// Removes placeholder flag from the previous local-only auth implementation.
  Future<void> _clearLegacyLocalFlag() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_kLegacySignedIn)) {
      await prefs.remove(_kLegacySignedIn);
    }
  }
}

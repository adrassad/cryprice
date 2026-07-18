import 'package:cryprice_frontend/features/auth/domain/entities/auth_user.dart';

/// Result of [restoreSession]: whether the user is signed in and which profile to show.
abstract class AuthRestoreResult {}

class AuthRestoreUnauthenticated extends AuthRestoreResult {}

class AuthRestoreAuthenticated extends AuthRestoreResult {
  AuthRestoreAuthenticated(this.user);
  final AuthUser user;
}

/// Session tokens are kept, but restore cannot be completed right now
/// (typically transient network/server degradation).
class AuthRestoreDeferred extends AuthRestoreResult {
  AuthRestoreDeferred([this.reason]);
  final String? reason;
}

abstract class AuthRepository {
  /// [GET /auth/me] and [POST /auth/refresh] as per backend contract.
  Future<AuthRestoreResult> restoreSession();

  /// LEGACY / native mobile: [POST /auth/google] with Google ID token.
  Future<AuthUser> signInWithGoogleIdToken(String idToken);

  /// [POST /auth/google/exchange] after Web OAuth redirect; stores tokens and returns user.
  Future<AuthUser> exchangeGoogleRedirectCode(String code);

  /// LEGACY GIS only: [GET /auth/google/redirect/start]. Not used by production Web login.
  Future<void> prepareGoogleRedirectStart(String returnTo);

  /// [POST /auth/logout], clears local session, revokes server refresh when possible.
  Future<void> logout({String? pushToken});
}

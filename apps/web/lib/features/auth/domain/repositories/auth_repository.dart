import 'package:crypto_tracker_app/features/auth/domain/entities/auth_user.dart';

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

  /// [POST /auth/google] with Google ID token; stores tokens and returns user.
  Future<AuthUser> signInWithGoogleIdToken(String idToken);

  /// [POST /auth/logout], clears local session, revokes server refresh when possible.
  Future<void> logout();
}

import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb, debugPrint;
import 'package:google_sign_in/google_sign_in.dart';

/// Optional web/client IDs via `--dart-define=GOOGLE_WEB_CLIENT_ID=...`
/// and `--dart-define=GOOGLE_SERVER_CLIENT_ID=...` (for Android ID token to backend).
class GoogleIdTokenProvider {
  GoogleIdTokenProvider() {
    const web = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID', defaultValue: '');
    const server = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID', defaultValue: '');
    if (kDebugMode && kIsWeb && web.isEmpty) {
      debugPrint(
        '[Auth][Web] GOOGLE_WEB_CLIENT_ID is not set. Pass a real Web OAuth client id, e.g.:\n'
        '  flutter run -d chrome '
        '--dart-define=GOOGLE_WEB_CLIENT_ID=123456789-xxx.apps.googleusercontent.com',
      );
    }
    _signIn = GoogleSignIn(
      scopes: const <String>['email', 'profile'],
      clientId: kIsWeb && web.isNotEmpty ? web : null,
      serverClientId: server.isNotEmpty ? server : null,
    );
  }

  late final GoogleSignIn _signIn;

  /// Interactive sign-in and returns a Google **ID token** (JWT) for [POST /auth/google], or null if cancelled.
  ///
  /// On web, uses GIS One Tap + [renderButton] (credential) flow; do not use [GoogleSignIn.signIn], which
  /// follows the legacy OAuth2 token path and may omit [idToken].
  Future<String?> getIdToken() async {
    if (kIsWeb) {
      return _getIdTokenWeb();
    }
    final GoogleSignInAccount? account = await _signIn.signIn();
    if (account == null) {
      return null;
    }
    final GoogleSignInAuthentication auth = await account.authentication;
    final String? id = auth.idToken;
    if (kDebugMode && (id == null || id.isEmpty)) {
      debugPrint(
        'GoogleIdTokenProvider: idToken is null. Configure OAuth client / serverClientId on Android if needed.',
      );
    }
    return id;
  }

  Future<String?> _getIdTokenWeb() async {
    // One Tap + GIS feed credential responses with JWT into the plugin; pair with the official [renderButton] in the UI.
    final GoogleSignInAccount? afterSilent = await _signIn.signInSilently();
    if (afterSilent != null) {
      if (kDebugMode) {
        debugPrint('[Auth][Web] account received: ${afterSilent.email}');
      }
      final String? id = await _idTokenFromAccount(afterSilent);
      if (kDebugMode) {
        debugPrint('[Auth][Web] idToken: ${id != null && id.isNotEmpty ? "received" : "null"}');
      }
      if (id != null && id.isNotEmpty) {
        return id;
      }
    } else {
      if (kDebugMode) {
        debugPrint('[Auth][Web] account: null (after signInSilently)');
      }
    }
    return _waitForWebIdToken();
  }

  Future<String?> _idTokenFromAccount(GoogleSignInAccount account) async {
    final GoogleSignInAuthentication auth = await account.authentication;
    return auth.idToken;
  }

  /// Waits for the GIS button / credential path to populate [GoogleSignInUserData] with a JWT.
  Future<String?> _waitForWebIdToken() async {
    final GoogleSignInAccount? now = _signIn.currentUser;
    if (now != null) {
      if (kDebugMode) {
        debugPrint('[Auth][Web] account received: ${now.email}');
      }
      final String? fromCurrent = await _idTokenFromAccount(now);
      if (kDebugMode) {
        debugPrint('[Auth][Web] idToken: ${fromCurrent != null && fromCurrent.isNotEmpty ? "received" : "null"}');
      }
      if (fromCurrent != null && fromCurrent.isNotEmpty) {
        return fromCurrent;
      }
    } else {
      if (kDebugMode) {
        debugPrint('[Auth][Web] account: null');
      }
    }
    final Completer<String?> completer = Completer<String?>();
    late final StreamSubscription<GoogleSignInAccount?> sub;
    sub = _signIn.onCurrentUserChanged.listen(
      (GoogleSignInAccount? account) async {
        if (account == null) {
          if (kDebugMode) {
            debugPrint('[Auth][Web] account: null');
          }
          return;
        }
        if (kDebugMode) {
          debugPrint('[Auth][Web] account received: ${account.email}');
        }
        final String? id = await _idTokenFromAccount(account);
        if (kDebugMode) {
          debugPrint('[Auth][Web] idToken: ${id != null && id.isNotEmpty ? "received" : "null"}');
        }
        if (id != null && id.isNotEmpty && !completer.isCompleted) {
          await sub.cancel();
          completer.complete(id);
        }
      },
    );
    try {
      return await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          if (kDebugMode) {
            debugPrint('[Auth][Web] idToken wait timed out');
          }
          return null;
        },
      );
    } finally {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
      await sub.cancel();
    }
  }

  Future<void> signOut() => _signIn.signOut();
}

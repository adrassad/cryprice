import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kAccess = 'cryprice_auth_access_token';
const _kRefresh = 'cryprice_auth_refresh_token';
const _kRefreshExpires = 'cryprice_auth_refresh_expires_at';

class StoredSessionTokens {
  const StoredSessionTokens({required this.access, required this.refresh, this.refreshExpiresAt});

  final String? access;
  final String? refresh;
  final String? refreshExpiresAt;
}

class AuthTokenStore {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<StoredSessionTokens> read() async {
    String? a;
    String? r;
    String? re;
    try {
      a = await _storage.read(key: _kAccess);
      r = await _storage.read(key: _kRefresh);
      re = await _storage.read(key: _kRefreshExpires);
    } on Object catch (e) {
      if (kIsWeb) {
        // Secure storage is limited on some web runs; allow empty session.
        debugPrint('AuthTokenStore read: $e');
      } else {
        rethrow;
      }
    }
    return StoredSessionTokens(access: a, refresh: r, refreshExpiresAt: re);
  }

  Future<void> write({
    required String access,
    required String refresh,
    String? refreshExpiresAt,
  }) async {
    await _storage.write(key: _kAccess, value: access);
    await _storage.write(key: _kRefresh, value: refresh);
    if (refreshExpiresAt == null) {
      await _storage.delete(key: _kRefreshExpires);
    } else {
      await _storage.write(key: _kRefreshExpires, value: refreshExpiresAt);
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
    await _storage.delete(key: _kRefreshExpires);
  }
}

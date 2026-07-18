import 'dart:js_interop';

import 'package:web/web.dart' as web;

bool get isAppCacheResetSupported => true;

/// Clears CacheStorage + service workers, optional session storage, auth tokens, then reloads.
///
/// Only call after explicit user confirmation.
Future<void> resetAppCache({required Future<void> Function() clearAuthTokens}) async {
  await clearAuthTokens();

  final caches = web.window.caches;
  final cacheKeys = (await caches.keys().toDart).toDart;
  for (final key in cacheKeys) {
    await caches.delete(key.toDart).toDart;
  }

  final swContainer = web.window.navigator.serviceWorker;
  final registrations = (await swContainer.getRegistrations().toDart).toDart;
  for (final registration in registrations) {
    await registration.unregister().toDart;
  }

  web.window.sessionStorage.clear();
  web.window.location.reload();
}

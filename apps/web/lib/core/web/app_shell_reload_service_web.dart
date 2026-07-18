import 'dart:js_interop';

import 'package:cryprice_frontend/core/web/app_version_service.dart';
import 'package:web/web.dart' as web;

bool get isAppShellReloadSupported => true;

/// Clears Flutter web caches and reloads without clearing auth tokens or local prefs.
Future<void> performAppShellReload({String? buildId}) async {
  if (buildId != null && hasReloadBeenAttemptedForBuild(buildId)) {
    return;
  }
  if (buildId != null) {
    markReloadAttemptedForBuild(buildId);
  }

  final swContainer = web.window.navigator.serviceWorker;
  try {
    final registration = await swContainer.getRegistration().toDart;
    final waiting = registration?.waiting;
    if (waiting != null) {
      waiting.postMessage('skipWaiting'.toJS);
    }
  } on Object {
    // Best-effort; reload still proceeds.
  }

  try {
    final caches = web.window.caches;
    final cacheKeys = (await caches.keys().toDart).toDart;
    for (final key in cacheKeys) {
      await caches.delete(key.toDart).toDart;
    }
  } on Object {
    // Best-effort.
  }

  try {
    final registrations = (await swContainer.getRegistrations().toDart).toDart;
    for (final registration in registrations) {
      await registration.unregister().toDart;
    }
  } on Object {
    // Best-effort.
  }

  web.window.location.reload();
}

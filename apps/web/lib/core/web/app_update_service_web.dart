import 'dart:js_interop';

import 'package:cryprice_frontend/core/auth/auth_flow_guard.dart';
import 'package:cryprice_frontend/core/auth/auth_flow_guard_keys.dart';
import 'package:cryprice_frontend/core/web/app_shell_reload_service.dart';
import 'package:web/web.dart' as web;

const _reloadGuardKey = 'cryprice_sw_reload_guard';

bool get isAppUpdateCheckSupported => true;

bool get hasDeferredAppUpdate =>
    web.window.sessionStorage.getItem(kSwReloadPendingKey) == '1';

/// Returns true when a new service worker is installed and waiting to activate.
Future<bool> checkForAppUpdate() async {
  if (isAuthFlowInProgress()) {
    return false;
  }

  final swContainer = web.window.navigator.serviceWorker;

  try {
    final registration = await swContainer.getRegistration().toDart;
    if (registration == null) {
      return false;
    }
    await registration.update().toDart;
    return registration.waiting != null;
  } on Object {
    return false;
  }
}

/// Activates a waiting service worker; page reloads via `controllerchange` in index.html.
Future<void> activatePendingAppUpdate() async {
  if (isAuthFlowInProgress()) {
    web.window.sessionStorage.setItem(kSwReloadPendingKey, '1');
    return;
  }
  if (web.window.sessionStorage.getItem(_reloadGuardKey) == '1') {
    return;
  }
  web.window.sessionStorage.setItem(_reloadGuardKey, '1');

  final swContainer = web.window.navigator.serviceWorker;
  final registration = await swContainer.getRegistration().toDart;
  final waiting = registration?.waiting;
  if (waiting == null) {
    web.window.sessionStorage.removeItem(_reloadGuardKey);
    return;
  }

  waiting.postMessage('skipWaiting'.toJS);
}

/// Applies a reload/update deferred while Google auth was in progress.
Future<void> applyDeferredAppUpdateAfterAuth() async {
  if (isAuthFlowInProgress()) {
    return;
  }

  final pendingReload = web.window.sessionStorage.getItem(kSwReloadPendingKey) == '1';
  web.window.sessionStorage.removeItem(kSwReloadPendingKey);

  if (!pendingReload) {
    return;
  }

  final hasWaiting = await checkForAppUpdate();
  if (hasWaiting) {
    await activatePendingAppUpdate();
    return;
  }

  await performAppShellReload();
}

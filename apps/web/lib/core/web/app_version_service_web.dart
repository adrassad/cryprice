import 'dart:convert';
import 'dart:js_interop';

import 'package:cryprice_frontend/core/web/app_version_info.dart';
import 'package:web/web.dart' as web;

const _storedBuildKey = 'cryprice_app_build_version';
const _lastReloadForBuildKey = 'cryprice_last_reload_for_build';

/// Fetches `/version.json` with cache-busting.
Future<AppVersionInfo?> fetchRemoteAppVersion() async {
  try {
    final url = '/version.json?t=${DateTime.now().millisecondsSinceEpoch}';
    final response = await web.window.fetch(url.toJS).toDart;
    if (!response.ok) {
      return null;
    }
    final text = (await response.text().toDart).toDart;
    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }
    final info = AppVersionInfo.fromJson(decoded);
    return info.isValid() ? info : null;
  } on Object {
    return null;
  }
}

String? readStoredAppBuildId() {
  final raw = web.window.localStorage.getItem(_storedBuildKey);
  if (raw == null || raw.isEmpty) {
    return null;
  }
  return raw;
}

Future<void> storeAppBuildId(String buildId) async {
  web.window.localStorage.setItem(_storedBuildKey, buildId);
}

bool hasReloadBeenAttemptedForBuild(String buildId) {
  return web.window.sessionStorage.getItem(_lastReloadForBuildKey) == buildId;
}

void markReloadAttemptedForBuild(String buildId) {
  web.window.sessionStorage.setItem(_lastReloadForBuildKey, buildId);
}

Future<AppVersionCheckResult> checkAppVersionChange() async {
  try {
    final remote = await fetchRemoteAppVersion();
    if (remote == null || !remote.isValid()) {
      return AppVersionCheckResult.unavailable;
    }

    if (!_runningBundleNeedsUpdate(remote)) {
      await storeAppBuildId(remote.build);
      return AppVersionCheckResult.upToDate;
    }

    if (hasReloadBeenAttemptedForBuild(remote.build)) {
      return AppVersionCheckResult.reloadAlreadyAttempted;
    }

    return AppVersionCheckResult.updateAvailable;
  } on Object {
    return AppVersionCheckResult.unavailable;
  }
}

bool _runningBundleNeedsUpdate(AppVersionInfo remote) {
  if (remote.build != kEmbeddedAppBuildId) {
    return true;
  }
  if (remote.authFlowVersion > kEmbeddedAuthFlowVersion) {
    return true;
  }
  return false;
}

/// Tests only — not used on web host.
void debugSetRemoteAppVersionForTesting(AppVersionInfo? info) {}

void debugSetStoredAppBuildIdForTesting(String? buildId) {}

void debugClearReloadAttemptsForTesting() {}

void resetAppVersionServiceForTesting() {}

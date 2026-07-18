import 'package:cryprice_frontend/core/web/app_version_info.dart';

AppVersionInfo? _debugRemoteVersion;
String? _debugStoredBuildId;
final Set<String> _debugReloadAttempts = <String>{};

/// Fetches `/version.json` with cache-busting (web only).
Future<AppVersionInfo?> fetchRemoteAppVersion() async => _debugRemoteVersion;

/// Last persisted deploy build id (web: localStorage).
String? readStoredAppBuildId() => _debugStoredBuildId;

Future<void> storeAppBuildId(String buildId) async {
  _debugStoredBuildId = buildId;
}

bool hasReloadBeenAttemptedForBuild(String buildId) =>
    _debugReloadAttempts.contains(buildId);

void markReloadAttemptedForBuild(String buildId) {
  _debugReloadAttempts.add(buildId);
}

/// Compares remote `/version.json` with the embedded bundle build id.
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

/// Tests only.
void debugSetRemoteAppVersionForTesting(AppVersionInfo? info) {
  _debugRemoteVersion = info;
}

/// Tests only.
void debugSetStoredAppBuildIdForTesting(String? buildId) {
  _debugStoredBuildId = buildId;
}

/// Tests only.
void debugClearReloadAttemptsForTesting() {
  _debugReloadAttempts.clear();
}

/// Tests only.
void resetAppVersionServiceForTesting() {
  _debugRemoteVersion = null;
  _debugStoredBuildId = null;
  _debugReloadAttempts.clear();
}

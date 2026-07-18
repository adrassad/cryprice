/// Build metadata for CryPrice web deploys (`/version.json` and compile-time defines).
class AppVersionInfo {
  const AppVersionInfo({
    required this.app,
    required this.build,
    required this.authFlowVersion,
    this.commit,
    this.builtAt,
  });

  final String app;
  final String build;
  final int authFlowVersion;
  final String? commit;
  final String? builtAt;

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    final authFlowRaw = json['authFlowVersion'];
    final authFlowVersion = authFlowRaw is int
        ? authFlowRaw
        : int.tryParse('$authFlowRaw') ?? 0;
    return AppVersionInfo(
      app: '${json['app'] ?? ''}',
      build: '${json['build'] ?? ''}',
      authFlowVersion: authFlowVersion,
      commit: json['commit']?.toString(),
      builtAt: json['builtAt']?.toString(),
    );
  }

  bool isValid() => app.isNotEmpty && build.isNotEmpty;
}

/// Build id compiled into the running Flutter web bundle.
///
/// Inject in CI via `--dart-define=APP_BUILD_ID=$GIT_SHA`.
const String kEmbeddedAppBuildId = String.fromEnvironment(
  'APP_BUILD_ID',
  defaultValue: 'dev',
);

/// Auth-flow generation compiled into the running bundle.
const int kEmbeddedAuthFlowVersion = int.fromEnvironment(
  'AUTH_FLOW_VERSION',
  defaultValue: 2,
);

enum AppVersionCheckResult {
  upToDate,
  updateAvailable,
  reloadAlreadyAttempted,
  unavailable,
}

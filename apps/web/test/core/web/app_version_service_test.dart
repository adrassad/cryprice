import 'package:cryprice_frontend/core/web/app_version_info.dart';
import 'package:cryprice_frontend/core/web/app_version_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(resetAppVersionServiceForTesting);

  const remoteDev = AppVersionInfo(
    app: 'cryprice-web',
    build: 'dev',
    authFlowVersion: 2,
  );

  const remoteNew = AppVersionInfo(
    app: 'cryprice-web',
    build: 'abc123',
    authFlowVersion: 2,
  );

  const remoteNewAuthFlow = AppVersionInfo(
    app: 'cryprice-web',
    build: 'dev',
    authFlowVersion: 99,
  );

  test('same version as embedded bundle is up to date', () async {
    debugSetRemoteAppVersionForTesting(remoteDev);
    expect(await checkAppVersionChange(), AppVersionCheckResult.upToDate);
    expect(readStoredAppBuildId(), 'dev');
  });

  test('newer remote build reports update available', () async {
    debugSetRemoteAppVersionForTesting(remoteNew);
    expect(await checkAppVersionChange(), AppVersionCheckResult.updateAvailable);
  });

  test('newer authFlowVersion reports update available', () async {
    debugSetRemoteAppVersionForTesting(remoteNewAuthFlow);
    expect(await checkAppVersionChange(), AppVersionCheckResult.updateAvailable);
  });

  test('reload guard prevents infinite reload loops', () async {
    debugSetRemoteAppVersionForTesting(remoteNew);
    markReloadAttemptedForBuild('abc123');
    expect(
      await checkAppVersionChange(),
      AppVersionCheckResult.reloadAlreadyAttempted,
    );
  });

  test('missing remote version is unavailable without throwing', () async {
    debugSetRemoteAppVersionForTesting(null);
    expect(await checkAppVersionChange(), AppVersionCheckResult.unavailable);
  });
}

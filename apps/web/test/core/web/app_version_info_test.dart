import 'package:cryprice_frontend/core/web/app_version_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromJson parses build, commit, builtAt, and authFlowVersion', () {
    final info = AppVersionInfo.fromJson(<String, dynamic>{
      'app': 'cryprice-web',
      'build': 'abc1234',
      'commit': 'abc1234567890abcdef1234567890abcdef123456',
      'builtAt': '2026-06-08T12:00:00Z',
      'authFlowVersion': 2,
    });

    expect(info.app, 'cryprice-web');
    expect(info.build, 'abc1234');
    expect(info.commit, 'abc1234567890abcdef1234567890abcdef123456');
    expect(info.builtAt, '2026-06-08T12:00:00Z');
    expect(info.authFlowVersion, 2);
    expect(info.isValid(), isTrue);
  });

  test('fromJson parses authFlowVersion from string', () {
    final info = AppVersionInfo.fromJson(<String, dynamic>{
      'app': 'cryprice-web',
      'build': 'dev',
      'authFlowVersion': '2',
    });

    expect(info.authFlowVersion, 2);
    expect(info.isValid(), isTrue);
  });

  test('fromJson rejects empty build id', () {
    final info = AppVersionInfo.fromJson(<String, dynamic>{
      'app': 'cryprice-web',
      'build': '',
      'authFlowVersion': 2,
    });

    expect(info.isValid(), isFalse);
  });

  test('embedded defaults match local dev manifest', () {
    expect(kEmbeddedAppBuildId, 'dev');
    expect(kEmbeddedAuthFlowVersion, 2);
  });
}

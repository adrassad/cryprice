import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('firebase SW build scripts', () {
    late Directory tempDir;
    late String rootDir;

    setUp(() {
      rootDir = Directory.current.path;
      tempDir = Directory.systemTemp.createTempSync('cryprice_fcm_sw_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('generate_firebase_messaging_sw.sh writes config from env', () async {
      final buildWeb = Directory('${tempDir.path}/build/web');
      buildWeb.createSync(recursive: true);

      final result = await Process.run(
        'bash',
        [
          '$rootDir/scripts/web/generate_firebase_messaging_sw.sh',
          buildWeb.path,
        ],
        environment: {
          'FIREBASE_PROJECT_ID': 'test-project',
          'FIREBASE_MESSAGING_SENDER_ID': '123456789',
          'FIREBASE_WEB_API_KEY': 'test-api-key',
          'FIREBASE_WEB_APP_ID': '1:123456789:web:abc123',
        },
      );

      expect(result.exitCode, 0, reason: result.stderr.toString());

      final output = File('${buildWeb.path}/firebase-messaging-sw.js');
      expect(output.existsSync(), isTrue);
      final content = output.readAsStringSync();
      expect(content, contains("projectId: 'test-project'"));
      expect(content, contains("apiKey: 'test-api-key'"));
      expect(content, contains("messagingSenderId: '123456789'"));
      expect(content, contains("appId: '1:123456789:web:abc123'"));
    });

    test(
      'generate_firebase_messaging_sw.sh falls back to dart-define args',
      () async {
        final buildWeb = Directory('${tempDir.path}/build/web2');
        buildWeb.createSync(recursive: true);

        final result = await Process.run(
          'bash',
          [
            '$rootDir/scripts/web/generate_firebase_messaging_sw.sh',
            buildWeb.path,
            '--dart-define=FIREBASE_PROJECT_ID=from-define',
            '--dart-define=FIREBASE_MESSAGING_SENDER_ID=999',
            '--dart-define=FIREBASE_WEB_API_KEY=define-key',
            '--dart-define=FIREBASE_WEB_APP_ID=1:999:web:def',
          ],
          environment: {
            // Ensure env does not override dart-define in this test.
            'FIREBASE_PROJECT_ID': '',
            'FIREBASE_MESSAGING_SENDER_ID': '',
            'FIREBASE_WEB_API_KEY': '',
            'FIREBASE_WEB_APP_ID': '',
          },
        );

        expect(result.exitCode, 0, reason: result.stderr.toString());

        final content =
            File(
              '${buildWeb.path}/firebase-messaging-sw.js',
            ).readAsStringSync();
        expect(content, contains("projectId: 'from-define'"));
        expect(content, contains("apiKey: 'define-key'"));
      },
    );

    test('firebase_messaging_sw.template.js handles notificationclick before messaging', () {
      final template = File(
        '$rootDir/scripts/web/firebase_messaging_sw.template.js',
      ).readAsStringSync();

      final notificationClickIndex = template.indexOf(
        "addEventListener('notificationclick'",
      );
      final messagingInitIndex = template.indexOf('firebase.messaging()');

      expect(notificationClickIndex, isNot(-1));
      expect(messagingInitIndex, isNot(-1));
      expect(
        notificationClickIndex,
        lessThan(messagingInitIndex),
        reason: 'notificationclick must be registered before firebase.messaging()',
      );

      expect(template, contains('event.stopImmediatePropagation()'));
      expect(template, contains('event.notification.close()'));

      expect(template, contains('data.deep_link'));
      expect(template, contains('fcmOptions.link'));
      expect(template, contains('webpush.fcmOptions.link'));

      expect(template, contains('clients.matchAll({'));
      expect(template, contains("type: 'window'"));
      expect(template, contains('includeUncontrolled: true'));

      expect(template, contains('await existingClient.focus()'));
      expect(template, contains('existingClient.postMessage({'));
      expect(template, contains("type: NOTIFICATION_CLICK_MESSAGE_TYPE"));
      expect(template, contains('deep_link: deepLink'));
      expect(template, contains('await clients.openWindow(deepLink)'));
    });

    test(
      'generate_firebase_messaging_sw.sh preserves notificationclick handler',
      () async {
        final buildWeb = Directory('${tempDir.path}/build/web4');
        buildWeb.createSync(recursive: true);

        final result = await Process.run(
          'bash',
          [
            '$rootDir/scripts/web/generate_firebase_messaging_sw.sh',
            buildWeb.path,
          ],
          environment: {
            'FIREBASE_PROJECT_ID': 'test-project',
            'FIREBASE_MESSAGING_SENDER_ID': '123456789',
            'FIREBASE_WEB_API_KEY': 'test-api-key',
            'FIREBASE_WEB_APP_ID': '1:123456789:web:abc123',
          },
        );

        expect(result.exitCode, 0, reason: result.stderr.toString());

        final content =
            File(
              '${buildWeb.path}/firebase-messaging-sw.js',
            ).readAsStringSync();

        expect(content, contains("addEventListener('notificationclick'"));
        expect(content, contains('event.stopImmediatePropagation()'));
        expect(content, contains('clients.matchAll({'));
        expect(content, contains('existingClient.postMessage({'));
        expect(content, contains('clients.openWindow(deepLink)'));
      },
    );

    test('inject_firebase_into_flutter_sw.sh is idempotent', () async {
      final buildWeb = Directory('${tempDir.path}/build/web3');
      buildWeb.createSync(recursive: true);

      final flutterSw = File('${buildWeb.path}/flutter_service_worker.js');
      flutterSw.writeAsStringSync("'use strict';\n// flutter sw\n");

      File(
        '${buildWeb.path}/firebase-messaging-sw.js',
      ).writeAsStringSync('// fcm\n');

      for (var i = 0; i < 2; i++) {
        final result = await Process.run('bash', [
          '$rootDir/scripts/web/inject_firebase_into_flutter_sw.sh',
          buildWeb.path,
        ]);
        expect(result.exitCode, 0, reason: result.stderr.toString());
      }

      final content = flutterSw.readAsStringSync();
      expect(
        content.startsWith("importScripts('firebase-messaging-sw.js');"),
        isTrue,
      );
      expect(
        content.split("importScripts('firebase-messaging-sw.js');").length,
        2,
      );

      final mode = flutterSw.statSync().mode;
      expect(
        mode & 0x004,
        isNot(0),
        reason: 'SW file should be world-readable (644)',
      );
    });
  });
}

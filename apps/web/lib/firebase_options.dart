import 'package:cryprice_frontend/core/config/push_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase options from `--dart-define` (see [PushConfig]).
///
/// Replace with FlutterFire CLI output when available; keep the same entry point.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: PushConfig.androidApiKey,
        appId: PushConfig.androidAppId,
        messagingSenderId: PushConfig.messagingSenderId,
        projectId: PushConfig.projectId,
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: PushConfig.iosApiKey,
        appId: PushConfig.iosAppId,
        messagingSenderId: PushConfig.messagingSenderId,
        projectId: PushConfig.projectId,
        iosBundleId: PushConfig.iosBundleId,
      );

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: PushConfig.webApiKey,
        appId: PushConfig.webAppId,
        messagingSenderId: PushConfig.messagingSenderId,
        projectId: PushConfig.projectId,
        authDomain: '${PushConfig.projectId}.firebaseapp.com',
      );
}

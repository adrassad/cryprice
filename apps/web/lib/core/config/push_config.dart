/// Firebase / FCM client configuration via `--dart-define`.
///
/// Web push also requires [webVapidKey]. The FCM service worker fragment is
/// generated post-build into `build/web/firebase-messaging-sw.js` and loaded
/// via `importScripts` from `flutter_service_worker.js` (see `scripts/web/`).
class PushConfig {
  const PushConfig._();

  static const String webVapidKey = String.fromEnvironment(
    'FIREBASE_WEB_VAPID_KEY',
    defaultValue: '',
  );

  static const String androidApiKey = String.fromEnvironment(
    'FIREBASE_ANDROID_API_KEY',
    defaultValue: '',
  );

  static const String iosApiKey = String.fromEnvironment(
    'FIREBASE_IOS_API_KEY',
    defaultValue: '',
  );

  static const String webApiKey = String.fromEnvironment(
    'FIREBASE_WEB_API_KEY',
    defaultValue: '',
  );

  static const String androidAppId = String.fromEnvironment(
    'FIREBASE_ANDROID_APP_ID',
    defaultValue: '',
  );

  static const String iosAppId = String.fromEnvironment(
    'FIREBASE_IOS_APP_ID',
    defaultValue: '',
  );

  static const String webAppId = String.fromEnvironment(
    'FIREBASE_WEB_APP_ID',
    defaultValue: '',
  );

  static const String messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '',
  );

  static const String projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: '',
  );

  static const String iosBundleId = String.fromEnvironment(
    'FIREBASE_IOS_BUNDLE_ID',
    defaultValue: 'com.example.apiBinanceApp',
  );

  static const String androidNotificationChannelId = 'cryprice_alerts';

  static bool get isFirebaseConfigured {
    if (messagingSenderId.isEmpty || projectId.isEmpty) {
      return false;
    }
    if (webApiKey.isNotEmpty && webAppId.isNotEmpty) {
      return true;
    }
    if (androidApiKey.isNotEmpty && androidAppId.isNotEmpty) {
      return true;
    }
    if (iosApiKey.isNotEmpty && iosAppId.isNotEmpty) {
      return true;
    }
    return false;
  }
}

import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

enum PushPlatform {
  android('android'),
  ios('ios'),
  web('web');

  const PushPlatform(this.apiValue);

  final String apiValue;

  static PushPlatform current() {
    if (kIsWeb) {
      return PushPlatform.web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return PushPlatform.ios;
      case TargetPlatform.android:
        return PushPlatform.android;
      default:
        return PushPlatform.android;
    }
  }
}

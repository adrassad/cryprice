import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import '../../../../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> pushBackgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint(
    '[Push][Background] messageId=${message.messageId} type=${message.data['type']}',
  );
}

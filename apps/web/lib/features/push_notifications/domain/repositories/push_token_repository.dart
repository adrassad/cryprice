import 'package:cryprice_frontend/features/push_notifications/domain/entities/push_platform.dart';

abstract class PushTokenRepository {
  Future<void> registerToken({
    required String token,
    required PushPlatform platform,
  });

  Future<void> unregisterToken(String token);

  Future<String?> readLastRegisteredToken();
}

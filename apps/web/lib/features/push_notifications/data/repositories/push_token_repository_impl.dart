import 'package:cryprice_frontend/features/push_notifications/data/datasources/push_token_local_store.dart';
import 'package:cryprice_frontend/features/push_notifications/data/datasources/push_token_remote_datasource.dart';
import 'package:cryprice_frontend/features/push_notifications/domain/entities/push_platform.dart';
import 'package:cryprice_frontend/features/push_notifications/domain/repositories/push_token_repository.dart';

class PushTokenRepositoryImpl implements PushTokenRepository {
  PushTokenRepositoryImpl({
    required PushTokenRemoteDataSource remote,
    required PushTokenLocalStore localStore,
  })  : _remote = remote,
        _localStore = localStore;

  final PushTokenRemoteDataSource _remote;
  final PushTokenLocalStore _localStore;

  @override
  Future<void> registerToken({
    required String token,
    required PushPlatform platform,
  }) async {
    await _remote.registerToken(token: token, platform: platform);
    await _localStore.writeLastRegisteredToken(token);
  }

  @override
  Future<void> unregisterToken(String token) async {
    try {
      await _remote.unregisterToken(token);
    } finally {
      final last = await _localStore.readLastRegisteredToken();
      if (last == token) {
        await _localStore.clearLastRegisteredToken();
      }
    }
  }

  @override
  Future<String?> readLastRegisteredToken() {
    return _localStore.readLastRegisteredToken();
  }
}

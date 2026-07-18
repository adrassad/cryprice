import 'package:cryprice_frontend/features/auth/domain/services/auth_session_service.dart';
import 'package:cryprice_frontend/features/push_notifications/data/datasources/push_token_remote_datasource.dart';
import 'package:cryprice_frontend/features/push_notifications/domain/entities/push_platform.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PushTokenRemoteDataSource', () {
    test('POST /push-tokens with platform and bearer token', () async {
      RequestOptions? captured;
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            captured = options;
            handler.resolve(
              Response<dynamic>(requestOptions: options, statusCode: 201),
            );
          },
        ),
      );
      final dataSource = PushTokenRemoteDataSource(
        sessionService: _StaticSessionService('access-token'),
        dio: dio,
      );

      await dataSource.registerToken(
        token: 'fcm-token-abc',
        platform: PushPlatform.web,
      );

      expect(captured?.path, '/push-tokens');
      expect(captured?.method, 'POST');
      expect(captured?.headers['Authorization'], 'Bearer access-token');
      expect(captured?.data, {
        'platform': 'web',
        'token': 'fcm-token-abc',
        'enabled': true,
      });
    });

    test('DELETE /push-tokens/by-token with token body', () async {
      RequestOptions? captured;
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            captured = options;
            handler.resolve(
              Response<dynamic>(requestOptions: options, statusCode: 204),
            );
          },
        ),
      );
      final dataSource = PushTokenRemoteDataSource(
        sessionService: _StaticSessionService('access-token'),
        dio: dio,
      );

      await dataSource.unregisterToken('fcm-token-abc');

      expect(captured?.path, '/push-tokens/by-token');
      expect(captured?.method, 'DELETE');
      expect(captured?.data, {'token': 'fcm-token-abc'});
    });
  });
}

class _StaticSessionService implements AuthSessionService {
  _StaticSessionService(this.accessToken);

  final String accessToken;

  @override
  Future<T> authorized<T>(Future<T> Function(String accessToken) request) {
    return request(accessToken);
  }
}

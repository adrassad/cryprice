import 'package:cryprice_frontend/core/config/cryprice_backend_config.dart';
import 'package:cryprice_frontend/core/network/api_error_parser.dart';
import 'package:cryprice_frontend/features/auth/domain/services/auth_session_service.dart';
import 'package:cryprice_frontend/features/push_notifications/domain/entities/push_platform.dart';
import 'package:dio/dio.dart';

class PushTokenRemoteDataSource {
  PushTokenRemoteDataSource({
    required AuthSessionService sessionService,
    Dio? dio,
    String? baseUrl,
  })  : _sessionService = sessionService,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? crypriceBackendBaseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                headers: const <String, Object?>{
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            );

  final AuthSessionService _sessionService;
  final Dio _dio;

  Future<void> registerToken({
    required String token,
    required PushPlatform platform,
  }) async {
    try {
      await _sessionService.authorized(
        (accessToken) => _dio.post<dynamic>(
          '/push-tokens',
          data: <String, dynamic>{
            'platform': platform.apiValue,
            'token': token,
            'enabled': true,
          },
          options: Options(
            headers: <String, Object?>{'Authorization': 'Bearer $accessToken'},
          ),
        ),
      );
    } on Object catch (e) {
      throw parseApiError(e);
    }
  }

  Future<void> unregisterToken(String token) async {
    try {
      await _sessionService.authorized(
        (accessToken) => _dio.delete<dynamic>(
          '/push-tokens/by-token',
          data: <String, dynamic>{'token': token},
          options: Options(
            headers: <String, Object?>{'Authorization': 'Bearer $accessToken'},
          ),
        ),
      );
    } on Object catch (e) {
      throw parseApiError(e);
    }
  }
}

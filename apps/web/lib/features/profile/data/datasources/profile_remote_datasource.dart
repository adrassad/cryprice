import 'package:cryprice_frontend/core/config/cryprice_backend_config.dart';
import 'package:cryprice_frontend/core/network/api_error_parser.dart';
import 'package:cryprice_frontend/features/auth/domain/services/auth_session_service.dart';
import 'package:cryprice_frontend/features/profile/data/models/profile_responses.dart';
import 'package:cryprice_frontend/features/profile/domain/entities/public_user.dart';
import 'package:dio/dio.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource({
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

  Future<PublicUser> getMe() async {
    try {
      final response = await _sessionService.authorized(
        (token) => _dio.get<dynamic>(
          '/users/me',
          options: Options(headers: <String, Object?>{'Authorization': 'Bearer $token'}),
        ),
      );
      final data = response.data;
      if (data is Map<String, Object?>) {
        return ProfileResponse.fromJson(data).user;
      }
      if (data is Map) {
        return ProfileResponse.fromJson(data.cast<String, Object?>()).user;
      }
      return const PublicUser();
    } on Object catch (e) {
      throw parseApiError(e);
    }
  }

  Future<PublicUser> updateProfile(Map<String, Object?> patch) async {
    try {
      final response = await _sessionService.authorized(
        (token) => _dio.patch<dynamic>(
          '/users/me',
          data: patch,
          options: Options(headers: <String, Object?>{'Authorization': 'Bearer $token'}),
        ),
      );
      final data = response.data;
      if (data is Map<String, Object?>) {
        return ProfileResponse.fromJson(data).user;
      }
      if (data is Map) {
        return ProfileResponse.fromJson(data.cast<String, Object?>()).user;
      }
      return const PublicUser();
    } on Object catch (e) {
      throw parseApiError(e);
    }
  }

  Future<TelegramLinkResponse> createTelegramLink() async {
    try {
      final response = await _sessionService.authorized(
        (token) => _dio.post<dynamic>(
          '/auth/link/telegram',
          options: Options(
            headers: <String, Object?>{'Authorization': 'Bearer $token'},
          ),
        ),
      );
      final data = response.data;
      if (data is Map<String, Object?>) {
        return TelegramLinkResponse.fromJson(data);
      }
      if (data is Map) {
        return TelegramLinkResponse.fromJson(data.cast<String, Object?>());
      }
      throw const FormatException('Invalid link response');
    } on Object catch (e) {
      throw parseApiError(e);
    }
  }
}

class TelegramLinkResponse {
  const TelegramLinkResponse({
    required this.telegramDeepLink,
    required this.expiresAt,
    required this.tokenId,
  });

  final String telegramDeepLink;
  final String expiresAt;
  final String tokenId;

  factory TelegramLinkResponse.fromJson(Map<String, Object?> m) {
    return TelegramLinkResponse(
      telegramDeepLink: (m['telegramDeepLink'] ?? '').toString(),
      expiresAt: (m['expiresAt'] ?? '').toString(),
      tokenId: (m['tokenId'] ?? '').toString(),
    );
  }
}

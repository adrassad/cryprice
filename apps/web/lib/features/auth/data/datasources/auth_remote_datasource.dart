import 'package:crypto_tracker_app/core/config/auth_backend_config.dart';
import 'package:crypto_tracker_app/features/auth/domain/entities/auth_user.dart';
import 'package:crypto_tracker_app/features/auth/domain/exceptions/auth_api_exception.dart';
import 'package:dio/dio.dart';

/// Calls `/auth/*` on [authBackendBaseUrl] (see `lib/core/config/auth_backend_config.dart`).
class AuthRemoteDataSource {
  AuthRemoteDataSource({Dio? dio, String? baseUrl})
    : _dio = dio ?? _buildDio(baseUrl ?? authBackendBaseUrl);

  final Dio _dio;

  static Dio _buildDio(String base) {
    return Dio(
      BaseOptions(
        baseUrl: base,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: <String, dynamic>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  /// `POST /auth/google` with `{ "idToken": "..." }`.
  Future<AuthTokenBundle> postAuthGoogle(String idToken) async {
    try {
      final r = await _dio.post<dynamic>('/auth/google', data: <String, dynamic>{'idToken': idToken});
      return _parseTokenResponse(r.data, expectIsNewUser: true);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  /// `GET /auth/me` with bearer.
  Future<AuthUser> getMe(String accessToken) async {
    try {
      final r = await _dio.get<dynamic>(
        '/auth/me',
        options: Options(headers: <String, dynamic>{'Authorization': 'Bearer $accessToken'}),
      );
      return _parseUserPayload(r.data);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  /// `POST /auth/refresh`
  Future<AuthTokenBundle> postRefresh(String refreshToken) async {
    try {
      final r = await _dio.post<dynamic>(
        '/auth/refresh',
        data: <String, dynamic>{'refreshToken': refreshToken},
      );
      return _parseTokenResponse(r.data, expectIsNewUser: false);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  /// `POST /auth/logout`
  Future<void> postLogout(String refreshToken) async {
    try {
      await _dio.post<dynamic>('/auth/logout', data: <String, dynamic>{'refreshToken': refreshToken});
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  AuthUser _parseUserPayload(Object? data) {
    if (data is! Map) {
      throw AuthApiException('Invalid /auth/me response', statusCode: 200);
    }
    final m = data.cast<String, Object?>();
    final u = m['user'];
    if (u is Map) {
      return AuthUser.fromJson(u.cast<String, Object?>());
    }
    return AuthUser.fromJson(m);
  }

  AuthTokenBundle _parseTokenResponse(Object? data, {required bool expectIsNewUser}) {
    if (data is! Map) {
      throw AuthApiException('Invalid auth response', statusCode: 200);
    }
    final m = data.cast<String, Object?>();
    final at = m['accessToken'] as String?;
    final rt = m['refreshToken'] as String?;
    if (at == null || at.isEmpty || rt == null || rt.isEmpty) {
      throw AuthApiException('Invalid auth response: missing tokens', statusCode: 200);
    }
    final reAt = m['refreshExpiresAt'] as String?;
    final userObj = m['user'];
    if (userObj is! Map) {
      throw AuthApiException('Invalid auth response: user', statusCode: 200);
    }
    return AuthTokenBundle(
      accessToken: at,
      refreshToken: rt,
      refreshExpiresAt: reAt,
      user: AuthUser.fromJson(userObj.cast<String, Object?>()),
      isNewUser: expectIsNewUser ? m['isNewUser'] as bool? : null,
    );
  }

  AuthApiException _mapDio(DioException e) {
    final sc = e.response?.statusCode;
    final data = e.response?.data;
    if (data is Map) {
      final err = data['error'];
      if (err is Map) {
        final c = err['code'] as String?;
        final msg = err['message'] as String? ?? 'Request failed';
        return AuthApiException(msg, code: c, statusCode: sc);
      }
    }
    return AuthApiException(e.message ?? 'Network error', statusCode: sc);
  }
}

class AuthTokenBundle {
  const AuthTokenBundle({
    required this.accessToken,
    required this.refreshToken,
    this.refreshExpiresAt,
    required this.user,
    this.isNewUser,
  });

  final String accessToken;
  final String refreshToken;
  final String? refreshExpiresAt;
  final AuthUser user;
  final bool? isNewUser;
}

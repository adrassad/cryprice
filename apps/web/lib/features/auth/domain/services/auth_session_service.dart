import 'package:cryprice_frontend/core/network/api_error.dart';
import 'package:cryprice_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cryprice_frontend/features/auth/data/local/auth_token_store.dart';
import 'package:dio/dio.dart';

class AuthSessionService {
  AuthSessionService({
    required AuthTokenStore tokenStore,
    required AuthRemoteDataSource authRemoteDataSource,
  })  : _tokenStore = tokenStore,
        _authRemoteDataSource = authRemoteDataSource;

  final AuthTokenStore _tokenStore;
  final AuthRemoteDataSource _authRemoteDataSource;

  Future<T> authorized<T>(Future<T> Function(String accessToken) request) async {
    final stored = await _tokenStore.read();
    var access = stored.access;
    if (access == null || access.isEmpty) {
      access = await _refreshOrThrow(stored.refresh);
    }
    try {
      return await request(access);
    } on DioException catch (e) {
      if (e.response?.statusCode != 401) {
        rethrow;
      }
      final refreshed = await _refreshOrThrow(stored.refresh);
      return request(refreshed);
    }
  }

  Future<String> _refreshOrThrow(String? refreshToken) async {
    if (refreshToken == null || refreshToken.isEmpty) {
      await _tokenStore.clear();
      throw const ApiError(
        message: 'Необходимо снова войти в аккаунт.',
        code: 'UNAUTHENTICATED',
        statusCode: 401,
      );
    }
    try {
      final bundle = await _authRemoteDataSource.postRefresh(refreshToken);
      await _tokenStore.write(
        access: bundle.accessToken,
        refresh: bundle.refreshToken,
        refreshExpiresAt: bundle.refreshExpiresAt,
      );
      return bundle.accessToken;
    } on Object {
      await _tokenStore.clear();
      throw const ApiError(
        message: 'Сессия истекла. Войдите снова.',
        code: 'UNAUTHENTICATED',
        statusCode: 401,
      );
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:crypto_tracker_app/features/crypto_price/domain/exceptions/crypto_exception.dart';

abstract class BaseApiProvider {
  final Dio dio;

  BaseApiProvider({required String baseUrl, Dio? dio})
    : dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl));

  Future<Response> safeGet(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('DioException ($path): $e');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw CryptoException(CryptoErrorCode.noInternet);
      }
      throw CryptoException(CryptoErrorCode.fetchFailed);
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Unknown error ($path): $e\n$stack');
      }
      throw CryptoException(CryptoErrorCode.unknown);
    }
  }
}

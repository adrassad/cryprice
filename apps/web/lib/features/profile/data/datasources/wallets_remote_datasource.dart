import 'package:cryprice_frontend/core/config/cryprice_backend_config.dart';
import 'package:cryprice_frontend/core/network/api_error_parser.dart';
import 'package:cryprice_frontend/features/auth/domain/services/auth_session_service.dart';
import 'package:cryprice_frontend/features/profile/data/models/profile_responses.dart';
import 'package:cryprice_frontend/features/profile/domain/entities/wallet.dart';
import 'package:dio/dio.dart';

class WalletsRemoteDataSource {
  WalletsRemoteDataSource({
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

  Future<List<Wallet>> getWallets() async {
    try {
      final response = await _sessionService.authorized(
        (token) => _dio.get<dynamic>(
          '/wallets',
          options: Options(headers: <String, Object?>{'Authorization': 'Bearer $token'}),
        ),
      );
      final data = response.data;
      if (data is Map<String, Object?>) {
        return WalletsResponse.fromJson(data).wallets;
      }
      if (data is Map) {
        return WalletsResponse.fromJson(data.cast<String, Object?>()).wallets;
      }
      return const <Wallet>[];
    } on Object catch (e) {
      throw parseApiError(e);
    }
  }

  Future<Wallet> addWallet(String address, String? label) async {
    try {
      final response = await _sessionService.authorized(
        (token) => _dio.post<dynamic>(
          '/wallets',
          data: <String, Object?>{
            'address': address,
            if (label != null) 'label': label,
          },
          options: Options(headers: <String, Object?>{'Authorization': 'Bearer $token'}),
        ),
      );
      final data = response.data;
      if (data is Map<String, Object?>) {
        return WalletResponse.fromJson(data).wallet;
      }
      if (data is Map) {
        return WalletResponse.fromJson(data.cast<String, Object?>()).wallet;
      }
      return const Wallet(id: 0, address: '');
    } on Object catch (e) {
      throw parseApiError(e);
    }
  }

  Future<Wallet> updateWalletLabel(int walletId, String? label) async {
    try {
      final response = await _sessionService.authorized(
        (token) => _dio.patch<dynamic>(
          '/wallets/$walletId',
          data: <String, Object?>{'label': label},
          options: Options(headers: <String, Object?>{'Authorization': 'Bearer $token'}),
        ),
      );
      final data = response.data;
      if (data is Map<String, Object?>) {
        return WalletResponse.fromJson(data).wallet;
      }
      if (data is Map) {
        return WalletResponse.fromJson(data.cast<String, Object?>()).wallet;
      }
      return Wallet(id: walletId, address: '');
    } on Object catch (e) {
      throw parseApiError(e);
    }
  }

  Future<void> deleteWallet(int walletId) async {
    try {
      await _sessionService.authorized(
        (token) => _dio.delete<dynamic>(
          '/wallets/$walletId',
          options: Options(headers: <String, Object?>{'Authorization': 'Bearer $token'}),
        ),
      );
    } on Object catch (e) {
      throw parseApiError(e);
    }
  }
}

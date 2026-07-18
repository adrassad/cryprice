import 'package:cryprice_frontend/core/config/cryprice_backend_config.dart';
import 'package:cryprice_frontend/core/network/api_error_parser.dart';
import 'package:cryprice_frontend/features/alerts/data/models/inbox_alert_model.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/auth/domain/services/auth_session_service.dart';
import 'package:dio/dio.dart';

class AlertsInboxRemoteDataSource {
  AlertsInboxRemoteDataSource({
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

  Future<List<InboxAlert>> getAlerts() async {
    try {
      final response = await _sessionService.authorized(
        (token) => _dio.get<dynamic>(
          '/alerts',
          options: Options(headers: <String, Object?>{'Authorization': 'Bearer $token'}),
        ),
      );
      return _parseAlertsList(response.data);
    } on Object catch (e) {
      throw parseApiError(e);
    }
  }

  Future<InboxAlert> markAlertRead(String id) async {
    try {
      final response = await _sessionService.authorized(
        (token) => _dio.patch<dynamic>(
          '/alerts/$id/read',
          options: Options(headers: <String, Object?>{'Authorization': 'Bearer $token'}),
        ),
      );
      return _parseAlertResponse(response.data);
    } on Object catch (e) {
      throw parseApiError(e);
    }
  }

  Future<int> markAllAsRead() async {
    try {
      final response = await _sessionService.authorized(
        (token) => _dio.patch<dynamic>(
          '/alerts/read-all',
          options: Options(headers: <String, Object?>{'Authorization': 'Bearer $token'}),
        ),
      );
      return _parseUpdatedCount(response.data);
    } on Object catch (e) {
      throw parseApiError(e);
    }
  }

  List<InboxAlert> _parseAlertsList(Object? data) {
    if (data is Map<String, Object?>) {
      return AlertsListResponse.fromJson(data).alerts;
    }
    if (data is Map) {
      return AlertsListResponse.fromJson(data.cast<String, Object?>()).alerts;
    }
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => InboxAlertModel.fromJson(item.cast<String, Object?>()).toEntity())
          .toList(growable: false);
    }
    return const <InboxAlert>[];
  }

  InboxAlert _parseAlertResponse(Object? data) {
    if (data is Map<String, Object?>) {
      if (data.containsKey('alert')) {
        return InboxAlertResponse.fromJson(data).alert;
      }
      return InboxAlertModel.fromJson(data).toEntity();
    }
    if (data is Map) {
      final map = data.cast<String, Object?>();
      if (map.containsKey('alert')) {
        return InboxAlertResponse.fromJson(map).alert;
      }
      return InboxAlertModel.fromJson(map).toEntity();
    }
    return InboxAlertModel.fromJson(const <String, Object?>{}).toEntity();
  }

  static int _parseUpdatedCount(Object? data) {
    if (data is! Map) {
      return 0;
    }
    final map = data.cast<String, Object?>();
    final raw = map['updated_count'] ?? map['updatedCount'];
    if (raw is int && raw >= 0) {
      return raw;
    }
    if (raw is num && raw >= 0) {
      return raw.toInt();
    }
    if (raw != null) {
      final parsed = int.tryParse(raw.toString());
      if (parsed != null && parsed >= 0) {
        return parsed;
      }
    }
    return 0;
  }
}

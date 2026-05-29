import 'package:cryprice_frontend/core/config/cryprice_backend_config.dart';
import 'package:cryprice_frontend/core/network/api_error_parser.dart';
import 'package:cryprice_frontend/features/alerts/data/models/alert_rules_response.dart';
import 'package:cryprice_frontend/features/alerts/data/models/create_alert_rule_request.dart';
import 'package:cryprice_frontend/features/alerts/data/models/update_alert_rule_request.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/alert_rule.dart';
import 'package:cryprice_frontend/features/auth/domain/services/auth_session_service.dart';
import 'package:dio/dio.dart';

class AlertRulesRemoteDataSource {
  AlertRulesRemoteDataSource({
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

  Future<List<AlertRule>> getAlertRules() async {
    try {
      final response = await _sessionService.authorized(
        (token) => _dio.get<dynamic>(
          '/alert-rules',
          options: Options(headers: <String, Object?>{'Authorization': 'Bearer $token'}),
        ),
      );
      final data = response.data;
      if (data is Map<String, Object?>) {
        return AlertRulesResponse.fromJson(data).rules;
      }
      if (data is Map) {
        return AlertRulesResponse.fromJson(data.cast<String, Object?>()).rules;
      }
      return const <AlertRule>[];
    } on Object catch (e) {
      throw parseApiError(e);
    }
  }

  Future<AlertRule> createAlertRule(CreateAlertRuleRequest request) async {
    try {
      final response = await _sessionService.authorized(
        (token) => _dio.post<dynamic>(
          '/alert-rules',
          data: request.toJson(),
          options: Options(headers: <String, Object?>{'Authorization': 'Bearer $token'}),
        ),
      );
      return _parseRuleResponse(response.data);
    } on Object catch (e) {
      throw parseApiError(e);
    }
  }

  Future<AlertRule> updateAlertRule(String id, UpdateAlertRuleRequest request) async {
    try {
      final response = await _sessionService.authorized(
        (token) => _dio.patch<dynamic>(
          '/alert-rules/$id',
          data: request.toJson(),
          options: Options(headers: <String, Object?>{'Authorization': 'Bearer $token'}),
        ),
      );
      return _parseRuleResponse(response.data);
    } on Object catch (e) {
      throw parseApiError(e);
    }
  }

  AlertRule _parseRuleResponse(Object? data) {
    if (data is Map<String, Object?>) {
      return AlertRuleResponse.fromJson(data).rule;
    }
    if (data is Map) {
      return AlertRuleResponse.fromJson(data.cast<String, Object?>()).rule;
    }
    return AlertRuleResponse.fromJson(const <String, Object?>{}).rule;
  }
}

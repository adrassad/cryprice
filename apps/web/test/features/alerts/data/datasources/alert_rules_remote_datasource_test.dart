import 'package:cryprice_frontend/core/network/api_error.dart';
import 'package:cryprice_frontend/features/alerts/data/datasources/alert_rules_remote_datasource.dart';
import 'package:cryprice_frontend/features/alerts/data/models/create_alert_rule_request.dart';
import 'package:cryprice_frontend/features/alerts/data/models/update_alert_rule_request.dart';
import 'package:cryprice_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cryprice_frontend/features/auth/data/local/auth_token_store.dart';
import 'package:cryprice_frontend/features/auth/domain/entities/auth_user.dart';
import 'package:cryprice_frontend/features/auth/domain/services/auth_session_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('getAlertRules', () {
    test('parses successful response', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: _alertRulesListResponse(),
              ),
            );
          },
        ),
      );
      final dataSource = AlertRulesRemoteDataSource(
        sessionService: _StaticSessionService('access-token'),
        dio: dio,
      );

      final rules = await dataSource.getAlertRules();

      expect(rules, hasLength(1));
      expect(rules.single.id, 'rule-1');
      expect(rules.single.thresholdHf, '1.25');
      expect(rules.single.thresholdHfValue, 1.25);
      expect(rules.single.walletId, isNull);
      expect(rules.single.networkId, isNull);
      expect(rules.single.isGlobalRule, isTrue);
    });

    test('sends bearer Authorization header', () async {
      RequestOptions? capturedOptions;
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedOptions = options;
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: _alertRulesListResponse(),
              ),
            );
          },
        ),
      );
      final dataSource = AlertRulesRemoteDataSource(
        sessionService: _StaticSessionService('access-token'),
        dio: dio,
      );

      await dataSource.getAlertRules();

      expect(capturedOptions?.path, '/alert-rules');
      expect(capturedOptions?.headers['Authorization'], 'Bearer access-token');
    });

    test('follows AuthSessionService refresh behavior after 401', () async {
      final requestedAuthHeaders = <Object?>[];
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestedAuthHeaders.add(options.headers['Authorization']);
            if (options.headers['Authorization'] == 'Bearer expired-token') {
              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response<dynamic>(
                    requestOptions: options,
                    statusCode: 401,
                    data: const <String, Object?>{
                      'error': <String, Object?>{
                        'message': 'Unauthorized',
                        'code': 'UNAUTHENTICATED',
                      },
                    },
                  ),
                ),
              );
              return;
            }
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: _alertRulesListResponse(),
              ),
            );
          },
        ),
      );
      final tokenStore = _FakeTokenStore(
        access: 'expired-token',
        refresh: 'refresh-token',
      );
      final authRemote = _FakeAuthRemoteDataSource(
        refreshedAccess: 'fresh-token',
        refreshedRefresh: 'next-refresh-token',
      );
      final sessionService = AuthSessionService(
        tokenStore: tokenStore,
        authRemoteDataSource: authRemote,
      );
      final dataSource = AlertRulesRemoteDataSource(
        sessionService: sessionService,
        dio: dio,
      );

      final rules = await dataSource.getAlertRules();

      expect(rules.single.id, 'rule-1');
      expect(requestedAuthHeaders, ['Bearer expired-token', 'Bearer fresh-token']);
      expect(authRemote.refreshCalls, 1);
      expect(tokenStore.access, 'fresh-token');
    });

    test('maps API errors with parseApiError', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response<dynamic>(
                  requestOptions: options,
                  statusCode: 500,
                  data: const <String, Object?>{
                    'error': <String, Object?>{
                      'message': 'Alert rules unavailable',
                      'code': 'ALERT_RULES_UNAVAILABLE',
                    },
                  },
                ),
              ),
            );
          },
        ),
      );
      final dataSource = AlertRulesRemoteDataSource(
        sessionService: _StaticSessionService('access-token'),
        dio: dio,
      );

      await expectLater(
        dataSource.getAlertRules(),
        throwsA(
          isA<ApiError>()
              .having((error) => error.statusCode, 'statusCode', 500)
              .having((error) => error.code, 'code', 'ALERT_RULES_UNAVAILABLE')
              .having((error) => error.message, 'message', 'Alert rules unavailable'),
        ),
      );
    });
  });

  group('createAlertRule', () {
    test('posts request body and parses rule response', () async {
      Object? capturedData;
      RequestOptions? capturedOptions;
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedOptions = options;
            capturedData = options.data;
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 201,
                data: _alertRuleResponse(),
              ),
            );
          },
        ),
      );
      final dataSource = AlertRulesRemoteDataSource(
        sessionService: _StaticSessionService('access-token'),
        dio: dio,
      );
      final request = CreateAlertRuleRequest.globalHealthFactor(
        thresholdHf: '1.50',
      );

      final rule = await dataSource.createAlertRule(request);

      expect(capturedOptions?.path, '/alert-rules');
      expect(capturedOptions?.method, 'POST');
      expect(capturedOptions?.headers['Authorization'], 'Bearer access-token');
      expect(
        capturedData,
        <String, Object?>{
          'type': 'health_factor_threshold',
          'protocol': 'aave',
          'threshold_hf': '1.50',
          'direction': 'below',
          'enabled': true,
          'cooldown_minutes': 60,
          'wallet_id': null,
          'network_id': null,
        },
      );
      expect(rule.id, 'rule-1');
      expect(rule.thresholdHf, '1.25');
    });
  });

  group('updateAlertRule', () {
    test('patches request body and parses rule response', () async {
      Object? capturedData;
      RequestOptions? capturedOptions;
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedOptions = options;
            capturedData = options.data;
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: _alertRuleResponse(
                  thresholdHf: '1.80',
                  enabled: false,
                ),
              ),
            );
          },
        ),
      );
      final dataSource = AlertRulesRemoteDataSource(
        sessionService: _StaticSessionService('access-token'),
        dio: dio,
      );
      const request = UpdateAlertRuleRequest(
        thresholdHf: '1.80',
        enabled: false,
      );

      final rule = await dataSource.updateAlertRule('rule-1', request);

      expect(capturedOptions?.path, '/alert-rules/rule-1');
      expect(capturedOptions?.method, 'PATCH');
      expect(
        capturedData,
        <String, Object?>{
          'threshold_hf': '1.80',
          'enabled': false,
        },
      );
      expect(rule.thresholdHf, '1.80');
      expect(rule.enabled, isFalse);
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

class _FakeTokenStore extends AuthTokenStore {
  _FakeTokenStore({
    required this.access,
    required this.refresh,
  });

  String? access;
  String? refresh;
  String? refreshExpiresAt;
  var cleared = false;

  @override
  Future<StoredSessionTokens> read() async {
    return StoredSessionTokens(
      access: access,
      refresh: refresh,
      refreshExpiresAt: refreshExpiresAt,
    );
  }

  @override
  Future<void> write({
    required String access,
    required String refresh,
    String? refreshExpiresAt,
  }) async {
    this.access = access;
    this.refresh = refresh;
    this.refreshExpiresAt = refreshExpiresAt;
  }

  @override
  Future<void> clear() async {
    cleared = true;
    access = null;
    refresh = null;
    refreshExpiresAt = null;
  }
}

class _FakeAuthRemoteDataSource extends AuthRemoteDataSource {
  _FakeAuthRemoteDataSource({
    required this.refreshedAccess,
    required this.refreshedRefresh,
  }) : super(dio: Dio(BaseOptions(baseUrl: 'https://auth.test')));

  final String refreshedAccess;
  final String refreshedRefresh;
  var refreshCalls = 0;

  @override
  Future<AuthTokenBundle> postRefresh(String refreshToken) async {
    refreshCalls += 1;
    return AuthTokenBundle(
      accessToken: refreshedAccess,
      refreshToken: refreshedRefresh,
      user: const AuthUser(),
    );
  }
}

Map<String, Object?> _alertRulesListResponse() {
  return <String, Object?>{
    'rules': [_sampleRuleJson()],
  };
}

Map<String, Object?> _alertRuleResponse({
  String thresholdHf = '1.25',
  bool enabled = true,
}) {
  return <String, Object?>{
    'rule': <String, Object?>{
      ..._sampleRuleJson(),
      'threshold_hf': thresholdHf,
      'enabled': enabled,
    },
  };
}

Map<String, Object?> _sampleRuleJson() {
  return <String, Object?>{
    'id': 'rule-1',
    'user_id': 'user-42',
    'type': 'health_factor_threshold',
    'protocol': 'aave',
    'wallet_id': null,
    'network_id': null,
    'threshold_hf': '1.25',
    'direction': 'below',
    'enabled': true,
    'cooldown_minutes': 60,
    'last_triggered_at': null,
    'created_at': '2026-05-19T10:00:00.000Z',
    'updated_at': '2026-05-19T10:00:00.000Z',
  };
}

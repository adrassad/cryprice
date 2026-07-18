import 'package:cryprice_frontend/core/network/api_error.dart';
import 'package:cryprice_frontend/features/alerts/data/datasources/alerts_inbox_remote_datasource.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_payload.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_type.dart';
import 'package:cryprice_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cryprice_frontend/features/auth/data/local/auth_token_store.dart';
import 'package:cryprice_frontend/features/auth/domain/entities/auth_user.dart';
import 'package:cryprice_frontend/features/auth/domain/services/auth_session_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('getAlerts', () {
    test('parses successful response with supported alert types', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: _alertsListResponse(),
              ),
            );
          },
        ),
      );
      final dataSource = AlertsInboxRemoteDataSource(
        sessionService: _StaticSessionService('access-token'),
        dio: dio,
      );

      final alerts = await dataSource.getAlerts();

      expect(alerts, hasLength(4));

      final exposureNews = alerts[0];
      expect(exposureNews.id, 'alert-exposure');
      expect(exposureNews.type, InboxAlertType.riskNews);
      expect(exposureNews.isRead, isFalse);
      final exposurePayload = exposureNews.riskNewsPayload!;
      expect(exposurePayload.isExposureScope, isTrue);
      expect(exposurePayload.matchedAssets, ['WBTC']);
      expect(exposurePayload.primarySourceUrl, 'https://news.example/exposure');

      final globalNews = alerts[1];
      expect(globalNews.type, InboxAlertType.riskNews);
      final globalPayload = globalNews.riskNewsPayload!;
      expect(globalPayload.isGlobalScope, isTrue);
      expect(globalPayload.globalReason, 'Market-wide liquidity stress');
      expect(globalPayload.primarySourceUrl, isNull);
      expect(globalPayload.primarySourceTitle, 'Macro risk bulletin');

      final breach = alerts[2];
      expect(breach.type, InboxAlertType.healthFactorBreach);
      final breachPayload = breach.healthFactorPayload!;
      expect(breachPayload.healthFactor, '1.12');
      expect(breachPayload.thresholdHf, '1.25');
      expect(breachPayload.protocol, 'aave-v3');

      final recovery = alerts[3];
      expect(recovery.type, InboxAlertType.healthFactorRecovery);
      expect(recovery.healthFactorPayload!.previousHealthFactor, '1.05');
      expect(recovery.healthFactorPayload!.healthFactor, '1.40');
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
                data: _alertsListResponse(),
              ),
            );
          },
        ),
      );
      final dataSource = AlertsInboxRemoteDataSource(
        sessionService: _StaticSessionService('access-token'),
        dio: dio,
      );

      await dataSource.getAlerts();

      expect(capturedOptions?.path, '/alerts');
      expect(capturedOptions?.headers['Authorization'], 'Bearer access-token');
    });

    test('ignores unknown payload fields safely', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <String, Object?>{
                  'alerts': [
                    <String, Object?>{
                      'id': 'alert-unknown-fields',
                      'type': InboxAlertType.riskNews,
                      'severity': 'high',
                      'title': 'Risk',
                      'message': 'Body',
                      'created_at': '2026-05-20T08:00:00.000Z',
                      'read_at': null,
                      'payload': <String, Object?>{
                        'target_scope': 'exposure',
                        'matched_assets': ['ETH'],
                        'unexpected_nested': <String, Object?>{'foo': 'bar'},
                        'future_flag': true,
                      },
                    },
                  ],
                },
              ),
            );
          },
        ),
      );
      final dataSource = AlertsInboxRemoteDataSource(
        sessionService: _StaticSessionService('access-token'),
        dio: dio,
      );

      final alert = (await dataSource.getAlerts()).single;
      final payload = alert.riskNewsPayload!;

      expect(payload.matchedAssets, ['ETH']);
      expect(payload.targetScope, 'exposure');
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
                data: _alertsListResponse(),
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
      final dataSource = AlertsInboxRemoteDataSource(
        sessionService: sessionService,
        dio: dio,
      );

      final alerts = await dataSource.getAlerts();

      expect(alerts, hasLength(4));
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
                      'message': 'Alerts unavailable',
                      'code': 'ALERTS_UNAVAILABLE',
                    },
                  },
                ),
              ),
            );
          },
        ),
      );
      final dataSource = AlertsInboxRemoteDataSource(
        sessionService: _StaticSessionService('access-token'),
        dio: dio,
      );

      await expectLater(
        dataSource.getAlerts(),
        throwsA(
          isA<ApiError>()
              .having((error) => error.statusCode, 'statusCode', 500)
              .having((error) => error.code, 'code', 'ALERTS_UNAVAILABLE')
              .having((error) => error.message, 'message', 'Alerts unavailable'),
        ),
      );
    });
  });

  group('markAlertRead', () {
    test('patches read endpoint and parses alert response', () async {
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
                data: <String, Object?>{
                  'alert': <String, Object?>{
                    'id': 'alert-exposure',
                    'type': InboxAlertType.riskNews,
                    'severity': 'high',
                    'title': 'Exposure risk',
                    'message': 'Matched WBTC exposure',
                    'created_at': '2026-05-20T08:00:00.000Z',
                    'read_at': '2026-05-20T09:00:00.000Z',
                    'payload': <String, Object?>{
                      'target_scope': 'exposure',
                      'primary_source_url': 'https://news.example/exposure',
                    },
                  },
                },
              ),
            );
          },
        ),
      );
      final dataSource = AlertsInboxRemoteDataSource(
        sessionService: _StaticSessionService('access-token'),
        dio: dio,
      );

      final alert = await dataSource.markAlertRead('alert-exposure');

      expect(capturedOptions?.path, '/alerts/alert-exposure/read');
      expect(capturedOptions?.method, 'PATCH');
      expect(capturedOptions?.headers['Authorization'], 'Bearer access-token');
      expect(alert.id, 'alert-exposure');
      expect(alert.isRead, isTrue);
      expect(alert.readAt, '2026-05-20T09:00:00.000Z');
      expect(alert.payload, isA<InboxAlertRiskNewsPayload>());
    });
  });

  group('markAllAsRead', () {
    test('patches read-all endpoint and parses updated_count', () async {
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
                data: const <String, Object?>{'updated_count': 12},
              ),
            );
          },
        ),
      );
      final dataSource = AlertsInboxRemoteDataSource(
        sessionService: _StaticSessionService('access-token'),
        dio: dio,
      );

      final count = await dataSource.markAllAsRead();

      expect(capturedOptions?.path, '/alerts/read-all');
      expect(capturedOptions?.method, 'PATCH');
      expect(capturedOptions?.data, isNull);
      expect(capturedOptions?.headers['Authorization'], 'Bearer access-token');
      expect(count, 12);
      expect(capturedOptions?.path, isNot(contains('/alerts/alert-')));
    });

    test('returns 0 when updated_count is zero', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: const <String, Object?>{'updated_count': 0},
              ),
            );
          },
        ),
      );
      final dataSource = AlertsInboxRemoteDataSource(
        sessionService: _StaticSessionService('access-token'),
        dio: dio,
      );

      final count = await dataSource.markAllAsRead();

      expect(count, 0);
    });

    test('returns 0 when updated_count is missing or invalid', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: const <String, Object?>{'unexpected': true},
              ),
            );
          },
        ),
      );
      final dataSource = AlertsInboxRemoteDataSource(
        sessionService: _StaticSessionService('access-token'),
        dio: dio,
      );

      expect(await dataSource.markAllAsRead(), 0);
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
          },
        ),
      );
      final dataSource = AlertsInboxRemoteDataSource(
        sessionService: _StaticSessionService('access-token'),
        dio: dio,
      );

      await expectLater(
        dataSource.markAllAsRead(),
        throwsA(
          isA<ApiError>()
              .having((error) => error.statusCode, 'statusCode', 401)
              .having((error) => error.code, 'code', 'UNAUTHENTICATED')
              .having((error) => error.message, 'message', 'Unauthorized'),
        ),
      );
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

Map<String, Object?> _alertsListResponse() {
  return <String, Object?>{
    'alerts': <Object?>[
      <String, Object?>{
        'id': 'alert-exposure',
        'type': InboxAlertType.riskNews,
        'severity': 'high',
        'title': 'Exposure risk',
        'message': 'Matched WBTC exposure',
        'created_at': '2026-05-20T08:00:00.000Z',
        'read_at': null,
        'payload': <String, Object?>{
          'target_scope': 'exposure',
          'event_type': 'protocol_incident',
          'primary_source_url': 'https://news.example/exposure',
          'primary_source_title': 'Exposure incident',
          'matched_assets': <Object?>['WBTC'],
          'matched_protocols': <Object?>['aave-v3'],
          'matched_chains': <Object?>['ethereum'],
          'match_confidence': '0.91',
          'affected_assets': <Object?>['WBTC'],
          'affected_protocols': <Object?>['aave-v3'],
          'affected_chains': <Object?>['ethereum'],
          'matched_major_entities': <Object?>['Aave'],
        },
      },
      <String, Object?>{
        'id': 'alert-global',
        'type': InboxAlertType.riskNews,
        'severity': 'critical',
        'title': 'Global risk',
        'message': 'Macro event',
        'created_at': '2026-05-20T07:00:00.000Z',
        'read_at': null,
        'payload': <String, Object?>{
          'target_scope': 'global',
          'event_type': 'macro',
          'primary_source_url': null,
          'primary_source_title': 'Macro risk bulletin',
          'global_reason': 'Market-wide liquidity stress',
          'matched_major_entities': <Object?>['DeFi'],
        },
      },
      <String, Object?>{
        'id': 'alert-breach',
        'type': InboxAlertType.healthFactorBreach,
        'severity': 'warning',
        'title': 'HF below threshold',
        'message': 'Health factor crossed below 1.25',
        'created_at': '2026-05-20T06:00:00.000Z',
        'read_at': null,
        'payload': <String, Object?>{
          'protocol': 'aave-v3',
          'wallet_id': 'wallet-1',
          'network_id': 'ethereum',
          'health_factor': '1.12',
          'threshold_hf': '1.25',
          'direction': 'below',
          'status': 'warning',
          'status_label': 'Warning',
        },
      },
      <String, Object?>{
        'id': 'alert-recovery',
        'type': InboxAlertType.healthFactorRecovery,
        'severity': 'info',
        'title': 'HF recovered',
        'message': 'Health factor recovered above threshold',
        'created_at': '2026-05-20T05:00:00.000Z',
        'read_at': '2026-05-20T05:30:00.000Z',
        'payload': <String, Object?>{
          'protocol': 'aave-v3',
          'wallet_id': 'wallet-1',
          'network_id': 'ethereum',
          'health_factor': '1.40',
          'previous_health_factor': '1.05',
          'threshold_hf': '1.25',
          'direction': 'above',
          'status': 'safe',
          'status_label': 'Safe',
        },
      },
    ],
  };
}

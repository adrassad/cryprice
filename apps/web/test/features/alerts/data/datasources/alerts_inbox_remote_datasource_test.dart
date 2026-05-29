import 'package:cryprice_frontend/features/alerts/data/datasources/alerts_inbox_remote_datasource.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_type.dart';
import 'package:cryprice_frontend/features/auth/domain/services/auth_session_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('getAlerts', () {
    test('parses health factor alerts from API response', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'alerts': [
                    {
                      'id': '1',
                      'type': InboxAlertType.healthFactorBreach,
                      'severity': 'warning',
                      'title': 'HF below threshold',
                      'message': 'Health Factor dropped',
                      'created_at': '2026-05-20T08:00:00.000Z',
                      'current_hf': '1.12',
                      'previous_hf': '1.40',
                      'payload': {'threshold_hf': 1.25},
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

      final alerts = await dataSource.getAlerts();

      expect(alerts, hasLength(1));
      expect(alerts.first.type, InboxAlertType.healthFactorBreach);
      expect(alerts.first.healthFactorPayload?.healthFactor, '1.12');
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

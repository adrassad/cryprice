import 'package:cryprice_frontend/core/network/api_error.dart';
import 'package:cryprice_frontend/features/alerts/data/datasources/alerts_inbox_remote_datasource.dart';
import 'package:cryprice_frontend/features/alerts/data/repositories/alerts_inbox_repository_impl.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAlertsInboxRemoteDataSource extends Mock implements AlertsInboxRemoteDataSource {}

void main() {
  late MockAlertsInboxRemoteDataSource remote;
  late AlertsInboxRepositoryImpl repository;

  setUp(() {
    remote = MockAlertsInboxRemoteDataSource();
    repository = AlertsInboxRepositoryImpl(remote: remote);
  });

  test('getAlerts delegates to remote data source', () async {
    final alerts = <InboxAlert>[_sampleAlert()];
    when(() => remote.getAlerts()).thenAnswer((_) async => alerts);

    final result = await repository.getAlerts();

    expect(result, same(alerts));
    verify(() => remote.getAlerts()).called(1);
  });

  test('markAlertRead delegates to remote data source', () async {
    final alert = _sampleAlert(readAt: '2026-05-20T09:00:00.000Z');
    when(() => remote.markAlertRead('alert-1')).thenAnswer((_) async => alert);

    final result = await repository.markAlertRead('alert-1');

    expect(result, same(alert));
    verify(() => remote.markAlertRead('alert-1')).called(1);
  });

  test('getAlerts propagates remote errors', () async {
    const error = ApiError(
      message: 'Alerts unavailable',
      code: 'ALERTS_UNAVAILABLE',
      statusCode: 503,
    );
    when(() => remote.getAlerts()).thenAnswer((_) async {
      throw error;
    });

    expect(
      repository.getAlerts(),
      throwsA(
        isA<ApiError>()
            .having((e) => e.statusCode, 'statusCode', 503)
            .having((e) => e.code, 'code', 'ALERTS_UNAVAILABLE'),
      ),
    );
  });
}

InboxAlert _sampleAlert({String? readAt}) {
  return InboxAlert(
    id: 'alert-1',
    type: InboxAlertType.healthFactorBreach,
    severity: 'high',
    title: 'Risk',
    message: 'Body',
    createdAt: '2026-05-20T08:00:00.000Z',
    readAt: readAt,
  );
}

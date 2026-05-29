import 'package:bloc_test/bloc_test.dart';
import 'package:cryprice_frontend/core/network/api_error.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_type.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/get_alerts_usecase.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/mark_alert_read_usecase.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_cubit.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_error_codes.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAlertsUseCase extends Mock implements GetAlertsUseCase {}

class MockMarkAlertReadUseCase extends Mock implements MarkAlertReadUseCase {}

AlertsInboxCubit _buildCubit({
  required MockGetAlertsUseCase getAlertsUseCase,
  required MockMarkAlertReadUseCase markAlertReadUseCase,
  int pageSize = 2,
}) {
  return AlertsInboxCubit(
    getAlertsUseCase: getAlertsUseCase,
    markAlertReadUseCase: markAlertReadUseCase,
    pageSize: pageSize,
  );
}

void main() {
  late MockGetAlertsUseCase getAlertsUseCase;
  late MockMarkAlertReadUseCase markAlertReadUseCase;

  setUp(() {
    getAlertsUseCase = MockGetAlertsUseCase();
    markAlertReadUseCase = MockMarkAlertReadUseCase();
  });

  blocTest<AlertsInboxCubit, AlertsInboxState>(
    'load sorts newest first and applies first page',
    build: () {
      when(() => getAlertsUseCase.execute()).thenAnswer(
        (_) async => [
          _alert(id: 'older', createdAt: '2026-05-19T10:00:00.000Z'),
          _alert(id: 'newer', createdAt: '2026-05-20T10:00:00.000Z'),
          _alert(id: 'middle', createdAt: '2026-05-19T12:00:00.000Z'),
        ],
      );
      return _buildCubit(
        getAlertsUseCase: getAlertsUseCase,
        markAlertReadUseCase: markAlertReadUseCase,
        pageSize: 2,
      );
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<AlertsInboxState>().having((s) => s.status, 'status', AlertsInboxStatus.loading),
      isA<AlertsInboxState>()
          .having((s) => s.status, 'status', AlertsInboxStatus.loaded)
          .having((s) => s.alerts.map((a) => a.id).toList(), 'ids', ['newer', 'middle'])
          .having((s) => s.hasMore, 'hasMore', isTrue)
          .having((s) => s.unreadCount, 'unreadCount', 3),
    ],
  );

  blocTest<AlertsInboxCubit, AlertsInboxState>(
    'refresh preserves local read state when server still returns unread',
    build: () {
      when(() => getAlertsUseCase.execute()).thenAnswer(
        (_) async => [
          _alert(id: 'alert-1', createdAt: '2026-05-20T10:00:00.000Z'),
        ],
      );
      when(() => markAlertReadUseCase.execute('alert-1')).thenAnswer(
        (_) async => _alert(
          id: 'alert-1',
          createdAt: '2026-05-20T10:00:00.000Z',
          readAt: '2026-05-20T11:00:00.000Z',
        ),
      );
      return _buildCubit(
        getAlertsUseCase: getAlertsUseCase,
        markAlertReadUseCase: markAlertReadUseCase,
        pageSize: 5,
      );
    },
    act: (cubit) async {
      await cubit.load();
      await cubit.markAsRead('alert-1');
      when(() => getAlertsUseCase.execute()).thenAnswer(
        (_) async => [
          _alert(id: 'alert-1', createdAt: '2026-05-20T10:00:00.000Z'),
        ],
      );
      await cubit.refresh();
    },
    verify: (cubit) {
      expect(cubit.state.alerts.single.isRead, isTrue);
      expect(cubit.state.unreadCount, 0);
    },
  );

  blocTest<AlertsInboxCubit, AlertsInboxState>(
    'load with empty list enters empty status',
    build: () {
      when(() => getAlertsUseCase.execute()).thenAnswer((_) async => const <InboxAlert>[]);
      return _buildCubit(
        getAlertsUseCase: getAlertsUseCase,
        markAlertReadUseCase: markAlertReadUseCase,
      );
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<AlertsInboxState>().having((s) => s.status, 'status', AlertsInboxStatus.loading),
      isA<AlertsInboxState>()
          .having((s) => s.status, 'status', AlertsInboxStatus.empty)
          .having((s) => s.alerts, 'alerts', isEmpty)
          .having((s) => s.unreadCount, 'unreadCount', 0),
    ],
  );

  blocTest<AlertsInboxCubit, AlertsInboxState>(
    'loadMore appends next page without duplicate ids',
    build: () {
      when(() => getAlertsUseCase.execute()).thenAnswer(
        (_) async => [
          _alert(id: 'a1', createdAt: '2026-05-20T04:00:00.000Z'),
          _alert(id: 'a2', createdAt: '2026-05-20T03:00:00.000Z'),
          _alert(id: 'a3', createdAt: '2026-05-20T02:00:00.000Z'),
          _alert(id: 'a1', createdAt: '2026-05-20T01:00:00.000Z'),
        ],
      );
      return _buildCubit(
        getAlertsUseCase: getAlertsUseCase,
        markAlertReadUseCase: markAlertReadUseCase,
        pageSize: 2,
      );
    },
    act: (cubit) async {
      await cubit.load();
      await cubit.loadMore();
    },
    verify: (cubit) {
      expect(cubit.state.alerts.map((a) => a.id).toList(), ['a1', 'a2', 'a3']);
      expect(cubit.state.hasMore, isFalse);
    },
  );

  blocTest<AlertsInboxCubit, AlertsInboxState>(
    'markAsRead success updates unread count',
    build: () {
      when(() => getAlertsUseCase.execute()).thenAnswer(
        (_) async => [
          _alert(id: 'u1', createdAt: '2026-05-20T10:00:00.000Z'),
          _alert(
            id: 'u2',
            createdAt: '2026-05-20T09:00:00.000Z',
            readAt: '2026-05-20T08:00:00.000Z',
          ),
        ],
      );
      when(() => markAlertReadUseCase.execute('u1')).thenAnswer(
        (_) async => _alert(
          id: 'u1',
          createdAt: '2026-05-20T10:00:00.000Z',
          readAt: '2026-05-20T11:00:00.000Z',
        ),
      );
      return _buildCubit(
        getAlertsUseCase: getAlertsUseCase,
        markAlertReadUseCase: markAlertReadUseCase,
        pageSize: 5,
      );
    },
    act: (cubit) async {
      await cubit.load();
      await cubit.markAsRead('u1');
    },
    verify: (cubit) {
      expect(cubit.state.alerts.first.isRead, isTrue);
      expect(cubit.state.unreadCount, 0);
      verify(() => markAlertReadUseCase.execute('u1')).called(1);
    },
  );

  blocTest<AlertsInboxCubit, AlertsInboxState>(
    'markAsRead rolls back optimistic update on API failure',
    build: () {
      when(() => getAlertsUseCase.execute()).thenAnswer(
        (_) async => [
          _alert(id: 'rollback', createdAt: '2026-05-20T10:00:00.000Z'),
        ],
      );
      when(() => markAlertReadUseCase.execute('rollback')).thenAnswer((_) async {
        throw const ApiError(
          message: 'Failed to mark read',
          code: 'ALERT_READ_FAILED',
          statusCode: 503,
        );
      });
      return _buildCubit(
        getAlertsUseCase: getAlertsUseCase,
        markAlertReadUseCase: markAlertReadUseCase,
        pageSize: 5,
      );
    },
    act: (cubit) async {
      await cubit.load();
      final before = cubit.state;
      await cubit.markAsRead('rollback');
      expect(cubit.state.alerts.single.isRead, isFalse);
      expect(cubit.state.unreadCount, before.unreadCount);
      expect(cubit.state.markReadErrorCode, 'ALERT_READ_FAILED');
    },
  );

  blocTest<AlertsInboxCubit, AlertsInboxState>(
    'load maps 401 to localization-ready unauthenticated error code',
    build: () {
      when(() => getAlertsUseCase.execute()).thenAnswer((_) async {
        throw const ApiError(
          message: 'Unauthorized',
          code: AlertsInboxErrorCodes.unauthenticated,
          statusCode: 401,
        );
      });
      return _buildCubit(
        getAlertsUseCase: getAlertsUseCase,
        markAlertReadUseCase: markAlertReadUseCase,
      );
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<AlertsInboxState>().having((s) => s.status, 'status', AlertsInboxStatus.loading),
      isA<AlertsInboxState>()
          .having((s) => s.status, 'status', AlertsInboxStatus.failure)
          .having((s) => s.errorCode, 'errorCode', AlertsInboxErrorCodes.unauthenticated)
          .having((s) => s.requiresLogin, 'requiresLogin', isTrue)
          .having((s) => s.errorMessage, 'errorMessage', isNull),
    ],
  );

  blocTest<AlertsInboxCubit, AlertsInboxState>(
    'load maps network failures to NETWORK_ERROR code',
    build: () {
      when(() => getAlertsUseCase.execute()).thenAnswer((_) async {
        throw DioException(
          requestOptions: RequestOptions(path: '/alerts'),
          type: DioExceptionType.connectionError,
        );
      });
      return _buildCubit(
        getAlertsUseCase: getAlertsUseCase,
        markAlertReadUseCase: markAlertReadUseCase,
      );
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<AlertsInboxState>().having((s) => s.status, 'status', AlertsInboxStatus.loading),
      isA<AlertsInboxState>()
          .having((s) => s.status, 'status', AlertsInboxStatus.failure)
          .having((s) => s.errorCode, 'errorCode', AlertsInboxErrorCodes.network)
          .having((s) => s.errorMessage, 'errorMessage', isNull),
    ],
  );

  blocTest<AlertsInboxCubit, AlertsInboxState>(
    'loadUnreadOnly shows only unread alerts',
    build: () {
      when(() => getAlertsUseCase.execute()).thenAnswer(
        (_) async => [
          _alert(id: 'unread', createdAt: '2026-05-20T10:00:00.000Z'),
          _alert(
            id: 'read',
            createdAt: '2026-05-20T09:00:00.000Z',
            readAt: '2026-05-20T08:00:00.000Z',
          ),
        ],
      );
      return _buildCubit(
        getAlertsUseCase: getAlertsUseCase,
        markAlertReadUseCase: markAlertReadUseCase,
        pageSize: 5,
      );
    },
    act: (cubit) => cubit.loadUnreadOnly(),
    verify: (cubit) {
      expect(cubit.state.unreadOnly, isTrue);
      expect(cubit.state.alerts.map((a) => a.id).toList(), ['unread']);
      expect(cubit.state.unreadCount, 1);
    },
  );
}

InboxAlert _alert({
  required String id,
  required String createdAt,
  String? readAt,
}) {
  return InboxAlert(
    id: id,
    type: InboxAlertType.healthFactorBreach,
    severity: 'high',
    title: 'Title $id',
    message: 'Message $id',
    createdAt: createdAt,
    readAt: readAt,
  );
}

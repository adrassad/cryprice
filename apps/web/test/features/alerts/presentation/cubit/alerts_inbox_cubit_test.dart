import 'package:bloc_test/bloc_test.dart';
import 'package:cryprice_frontend/core/network/api_error.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_type.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/get_alerts_usecase.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/mark_alert_read_usecase.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/mark_all_alerts_read_usecase.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_cubit.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_error_codes.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAlertsUseCase extends Mock implements GetAlertsUseCase {}

class MockMarkAlertReadUseCase extends Mock implements MarkAlertReadUseCase {}

class MockMarkAllAlertsReadUseCase extends Mock implements MarkAllAlertsReadUseCase {}

AlertsInboxCubit _buildCubit({
  required MockGetAlertsUseCase getAlertsUseCase,
  required MockMarkAlertReadUseCase markAlertReadUseCase,
  required MockMarkAllAlertsReadUseCase markAllAlertsReadUseCase,
  int pageSize = 2,
}) {
  return AlertsInboxCubit(
    getAlertsUseCase: getAlertsUseCase,
    markAlertReadUseCase: markAlertReadUseCase,
    markAllAlertsReadUseCase: markAllAlertsReadUseCase,
    pageSize: pageSize,
  );
}

void main() {
  late MockGetAlertsUseCase getAlertsUseCase;
  late MockMarkAlertReadUseCase markAlertReadUseCase;
  late MockMarkAllAlertsReadUseCase markAllAlertsReadUseCase;

  setUp(() {
    getAlertsUseCase = MockGetAlertsUseCase();
    markAlertReadUseCase = MockMarkAlertReadUseCase();
    markAllAlertsReadUseCase = MockMarkAllAlertsReadUseCase();
    when(() => markAllAlertsReadUseCase.execute()).thenAnswer((_) async => 0);
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
        markAllAlertsReadUseCase: markAllAlertsReadUseCase,
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
        markAllAlertsReadUseCase: markAllAlertsReadUseCase,
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
        markAllAlertsReadUseCase: markAllAlertsReadUseCase,
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
        markAllAlertsReadUseCase: markAllAlertsReadUseCase,
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
        markAllAlertsReadUseCase: markAllAlertsReadUseCase,
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
        markAllAlertsReadUseCase: markAllAlertsReadUseCase,
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
        markAllAlertsReadUseCase: markAllAlertsReadUseCase,
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
        markAllAlertsReadUseCase: markAllAlertsReadUseCase,
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
        markAllAlertsReadUseCase: markAllAlertsReadUseCase,
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

  blocTest<AlertsInboxCubit, AlertsInboxState>(
    'markAllAsRead does nothing when unreadCount is zero',
    build: () {
      when(() => getAlertsUseCase.execute()).thenAnswer(
        (_) async => [
          _alert(
            id: 'read-only',
            createdAt: '2026-05-20T10:00:00.000Z',
            readAt: '2026-05-20T09:00:00.000Z',
          ),
        ],
      );
      return _buildCubit(
        getAlertsUseCase: getAlertsUseCase,
        markAlertReadUseCase: markAlertReadUseCase,
        markAllAlertsReadUseCase: markAllAlertsReadUseCase,
        pageSize: 5,
      );
    },
    act: (cubit) async {
      await cubit.load();
      await cubit.markAllAsRead();
    },
    verify: (_) {
      verifyNever(() => markAllAlertsReadUseCase.execute());
    },
  );

  blocTest<AlertsInboxCubit, AlertsInboxState>(
    'markAllAsRead calls use case and clears unread count',
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
      when(() => markAllAlertsReadUseCase.execute()).thenAnswer((_) async => 1);
      return _buildCubit(
        getAlertsUseCase: getAlertsUseCase,
        markAlertReadUseCase: markAlertReadUseCase,
        markAllAlertsReadUseCase: markAllAlertsReadUseCase,
        pageSize: 5,
      );
    },
    act: (cubit) async {
      await cubit.load();
      await cubit.markAllAsRead();
    },
    verify: (cubit) {
      verify(() => markAllAlertsReadUseCase.execute()).called(1);
      expect(cubit.state.unreadCount, 0);
      expect(cubit.state.isMarkingAllRead, isFalse);
      expect(cubit.state.alerts.every((alert) => alert.isRead), isTrue);
    },
  );

  blocTest<AlertsInboxCubit, AlertsInboxState>(
    'markAllAsRead marks cache-only alerts outside visible page',
    build: () {
      when(() => getAlertsUseCase.execute()).thenAnswer(
        (_) async => [
          _alert(id: 'visible-1', createdAt: '2026-05-20T10:00:00.000Z'),
          _alert(id: 'visible-2', createdAt: '2026-05-20T09:00:00.000Z'),
          _alert(id: 'cached-only', createdAt: '2026-05-20T08:00:00.000Z'),
        ],
      );
      when(() => markAllAlertsReadUseCase.execute()).thenAnswer((_) async => 3);
      return _buildCubit(
        getAlertsUseCase: getAlertsUseCase,
        markAlertReadUseCase: markAlertReadUseCase,
        markAllAlertsReadUseCase: markAllAlertsReadUseCase,
        pageSize: 2,
      );
    },
    act: (cubit) async {
      await cubit.load();
      expect(cubit.state.alerts.map((a) => a.id).toList(), ['visible-1', 'visible-2']);
      await cubit.markAllAsRead();
    },
    verify: (cubit) {
      expect(cubit.state.unreadCount, 0);
      expect(cubit.state.alerts.every((alert) => alert.isRead), isTrue);
    },
  );

  blocTest<AlertsInboxCubit, AlertsInboxState>(
    'markAllAsRead rolls back on API failure',
    build: () {
      when(() => getAlertsUseCase.execute()).thenAnswer(
        (_) async => [
          _alert(id: 'fail-1', createdAt: '2026-05-20T10:00:00.000Z'),
          _alert(id: 'fail-2', createdAt: '2026-05-20T09:00:00.000Z'),
        ],
      );
      when(() => markAllAlertsReadUseCase.execute()).thenAnswer((_) async {
        throw const ApiError(
          message: 'Failed to mark all read',
          code: 'ALERT_READ_ALL_FAILED',
          statusCode: 503,
        );
      });
      return _buildCubit(
        getAlertsUseCase: getAlertsUseCase,
        markAlertReadUseCase: markAlertReadUseCase,
        markAllAlertsReadUseCase: markAllAlertsReadUseCase,
        pageSize: 5,
      );
    },
    act: (cubit) async {
      await cubit.load();
      final before = cubit.state;
      await cubit.markAllAsRead();
      expect(cubit.state.unreadCount, before.unreadCount);
      expect(cubit.state.alerts.every((alert) => !alert.isRead), isTrue);
      expect(cubit.state.markAllReadErrorCode, 'ALERT_READ_ALL_FAILED');
      expect(cubit.state.isMarkingAllRead, isFalse);
    },
  );

  blocTest<AlertsInboxCubit, AlertsInboxState>(
    'concurrent markAllAsRead calls invoke use case once',
    build: () {
      when(() => getAlertsUseCase.execute()).thenAnswer(
        (_) async => [
          _alert(id: 'u1', createdAt: '2026-05-20T10:00:00.000Z'),
        ],
      );
      when(() => markAllAlertsReadUseCase.execute()).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return 1;
      });
      return _buildCubit(
        getAlertsUseCase: getAlertsUseCase,
        markAlertReadUseCase: markAlertReadUseCase,
        markAllAlertsReadUseCase: markAllAlertsReadUseCase,
        pageSize: 5,
      );
    },
    act: (cubit) async {
      await cubit.load();
      final first = cubit.markAllAsRead();
      final second = cubit.markAllAsRead();
      await Future.wait<void>([first, second]);
    },
    verify: (_) {
      verify(() => markAllAlertsReadUseCase.execute()).called(1);
    },
  );

  blocTest<AlertsInboxCubit, AlertsInboxState>(
    'loadMore after markAllAsRead does not reveal unread cached alerts',
    build: () {
      when(() => getAlertsUseCase.execute()).thenAnswer(
        (_) async => [
          _alert(id: 'a1', createdAt: '2026-05-20T04:00:00.000Z'),
          _alert(id: 'a2', createdAt: '2026-05-20T03:00:00.000Z'),
          _alert(id: 'a3', createdAt: '2026-05-20T02:00:00.000Z'),
        ],
      );
      when(() => markAllAlertsReadUseCase.execute()).thenAnswer((_) async => 3);
      return _buildCubit(
        getAlertsUseCase: getAlertsUseCase,
        markAlertReadUseCase: markAlertReadUseCase,
        markAllAlertsReadUseCase: markAllAlertsReadUseCase,
        pageSize: 2,
      );
    },
    act: (cubit) async {
      await cubit.load();
      await cubit.markAllAsRead();
      await cubit.loadMore();
    },
    verify: (cubit) {
      expect(cubit.state.unreadCount, 0);
      expect(cubit.state.alerts.map((a) => a.id).toList(), ['a1', 'a2', 'a3']);
      expect(cubit.state.alerts.every((alert) => alert.isRead), isTrue);
    },
  );

  blocTest<AlertsInboxCubit, AlertsInboxState>(
    'focusAlert loads inbox and paginates until target alert is visible',
    build: () {
      when(() => getAlertsUseCase.execute()).thenAnswer(
        (_) async => [
          _alert(id: 'a1', createdAt: '2026-05-20T10:00:00.000Z'),
          _alert(id: 'a2', createdAt: '2026-05-19T10:00:00.000Z'),
          _alert(id: 'target', createdAt: '2026-05-18T10:00:00.000Z'),
        ],
      );
      return _buildCubit(
        getAlertsUseCase: getAlertsUseCase,
        markAlertReadUseCase: markAlertReadUseCase,
        markAllAlertsReadUseCase: markAllAlertsReadUseCase,
        pageSize: 2,
      );
    },
    act: (cubit) => cubit.focusAlert('target'),
    verify: (cubit) {
      expect(cubit.state.highlightedAlertId, 'target');
      expect(cubit.state.pendingFocusAlertId, 'target');
      expect(cubit.state.alerts.any((alert) => alert.id == 'target'), isTrue);
    },
  );

  blocTest<AlertsInboxCubit, AlertsInboxState>(
    'markFocusScrollCompleted clears pending focus alert id',
    build: () {
      when(() => getAlertsUseCase.execute()).thenAnswer(
        (_) async => [
          _alert(id: 'a1', createdAt: '2026-05-20T10:00:00.000Z'),
        ],
      );
      return _buildCubit(
        getAlertsUseCase: getAlertsUseCase,
        markAlertReadUseCase: markAlertReadUseCase,
        markAllAlertsReadUseCase: markAllAlertsReadUseCase,
      );
    },
    act: (cubit) async {
      await cubit.load();
      await cubit.focusAlert('a1');
      cubit.markFocusScrollCompleted('a1');
    },
    verify: (cubit) {
      expect(cubit.state.pendingFocusAlertId, isNull);
      expect(cubit.state.highlightedAlertId, 'a1');
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
    type: InboxAlertType.riskNews,
    severity: 'high',
    title: 'Title $id',
    message: 'Message $id',
    createdAt: createdAt,
    readAt: readAt,
  );
}

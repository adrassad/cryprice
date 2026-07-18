import 'package:cryprice_frontend/core/network/api_error.dart';
import 'package:cryprice_frontend/core/network/api_error_parser.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/get_alerts_usecase.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/mark_alert_read_usecase.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/mark_all_alerts_read_usecase.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_error_codes.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Page size for client-side pagination until the backend exposes cursor/offset APIs.
const int kAlertsInboxPageSize = 20;

class AlertsInboxCubit extends Cubit<AlertsInboxState> {
  AlertsInboxCubit({
    required GetAlertsUseCase getAlertsUseCase,
    required MarkAlertReadUseCase markAlertReadUseCase,
    required MarkAllAlertsReadUseCase markAllAlertsReadUseCase,
    int pageSize = kAlertsInboxPageSize,
  })  : _getAlertsUseCase = getAlertsUseCase,
        _markAlertReadUseCase = markAlertReadUseCase,
        _markAllAlertsReadUseCase = markAllAlertsReadUseCase,
        _pageSize = pageSize,
        super(const AlertsInboxState());

  final GetAlertsUseCase _getAlertsUseCase;
  final MarkAlertReadUseCase _markAlertReadUseCase;
  final MarkAllAlertsReadUseCase _markAllAlertsReadUseCase;
  final int _pageSize;

  List<InboxAlert> _fullAlertsCache = const <InboxAlert>[];
  final Set<String> _markReadInFlight = <String>{};
  bool _markAllReadInFlight = false;
  String? _focusAlertIdInFlight;
  bool _focusRefreshTriggered = false;

  Future<void> load() async {
    emit(
      state.copyWith(
        status: AlertsInboxStatus.loading,
        alerts: const <InboxAlert>[],
        unreadCount: 0,
        hasMore: false,
        isLoadingMore: false,
        clearError: true,
        clearMarkReadError: true,
        clearMarkAllReadError: true,
        isMarkingAllRead: false,
      ),
    );
    await _fetchAlerts(resetPagination: true, preserveReadState: false);
  }

  Future<void> refresh() async {
    final hasExistingAlerts = state.alerts.isNotEmpty;
    emit(
      state.copyWith(
        status: hasExistingAlerts
            ? AlertsInboxStatus.refreshing
            : AlertsInboxStatus.loading,
        clearError: true,
        clearMarkReadError: true,
        clearMarkAllReadError: true,
      ),
    );
    await _fetchAlerts(
      resetPagination: false,
      preserveReadState: true,
      preserveVisibleCount: hasExistingAlerts,
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) {
      return;
    }
    if (state.status != AlertsInboxStatus.loaded &&
        state.status != AlertsInboxStatus.empty) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, clearMarkReadError: true));
    final nextVisibleCount = state.alerts.length + _pageSize;
    _emitPagedState(visibleCount: nextVisibleCount, clearMarkReadError: true);
    emit(state.copyWith(isLoadingMore: false));
  }

  Future<void> loadUnreadOnly() async {
    emit(
      state.copyWith(
        status: AlertsInboxStatus.loading,
        unreadOnly: true,
        alerts: const <InboxAlert>[],
        hasMore: false,
        isLoadingMore: false,
        clearError: true,
        clearMarkReadError: true,
        clearMarkAllReadError: true,
        isMarkingAllRead: false,
      ),
    );
    await _fetchAlerts(resetPagination: true, preserveReadState: true);
  }

  void clearMarkReadError() {
    if (state.markReadErrorCode == null && state.markReadErrorMessage == null) {
      return;
    }
    emit(state.copyWith(clearMarkReadError: true));
  }

  void clearMarkAllReadError() {
    if (state.markAllReadErrorCode == null && state.markAllReadErrorMessage == null) {
      return;
    }
    emit(state.copyWith(clearMarkAllReadError: true));
  }

  Future<void> focusAlert(String alertId) async {
    final trimmedId = alertId.trim();
    if (trimmedId.isEmpty) {
      return;
    }

    _focusAlertIdInFlight = trimmedId;
    _focusRefreshTriggered = false;

    emit(
      state.copyWith(
        pendingFocusAlertId: trimmedId,
        highlightedAlertId: trimmedId,
      ),
    );

    await _resolveFocusAlert(trimmedId);
  }

  void markFocusScrollCompleted(String alertId) {
    final trimmedId = alertId.trim();
    if (trimmedId.isEmpty || state.pendingFocusAlertId != trimmedId) {
      return;
    }

    emit(state.copyWith(clearPendingFocusAlertId: true));
    _focusAlertIdInFlight = null;
    _focusRefreshTriggered = false;
  }

  void clearHighlightedAlert() {
    if (state.highlightedAlertId == null) {
      return;
    }
    emit(state.copyWith(clearHighlightedAlertId: true));
  }

  Future<void> _resolveFocusAlert(String alertId) async {
    if (_focusAlertIdInFlight != alertId) {
      return;
    }

    if (!_containsAlertInVisibleList(alertId)) {
      if (!_containsAlertInCache(alertId) && !_focusRefreshTriggered) {
        _focusRefreshTriggered = true;
        if (state.status == AlertsInboxStatus.initial) {
          await load();
        } else if (state.status != AlertsInboxStatus.loading &&
            state.status != AlertsInboxStatus.refreshing) {
          await refresh();
        } else {
          await _waitForFetchToSettle();
        }
      } else if (state.status == AlertsInboxStatus.loading ||
          state.status == AlertsInboxStatus.refreshing) {
        await _waitForFetchToSettle();
      }
      while (_focusAlertIdInFlight == alertId &&
          _containsAlertInCache(alertId) &&
          !_containsAlertInVisibleList(alertId) &&
          state.hasMore) {
        await loadMore();
      }
    }

    if (_focusAlertIdInFlight == alertId && _containsAlertInVisibleList(alertId)) {
      emit(
        state.copyWith(
          pendingFocusAlertId: alertId,
          highlightedAlertId: alertId,
        ),
      );
    }
  }

  Future<void> _waitForFetchToSettle() async {
    if (state.status != AlertsInboxStatus.loading &&
        state.status != AlertsInboxStatus.refreshing) {
      return;
    }

    await stream
        .firstWhere(
          (next) =>
              next.status != AlertsInboxStatus.loading &&
              next.status != AlertsInboxStatus.refreshing,
        )
        .timeout(const Duration(seconds: 30), onTimeout: () => state);
  }

  bool _containsAlertInCache(String alertId) {
    return _fullAlertsCache.any((alert) => alert.id == alertId);
  }

  bool _containsAlertInVisibleList(String alertId) {
    return state.alerts.any((alert) => alert.id == alertId);
  }

  Future<void> markAllAsRead() async {
    if (state.unreadCount == 0 || _markAllReadInFlight) {
      return;
    }

    final snapshot = state;
    final fullCacheSnapshot = List<InboxAlert>.from(_fullAlertsCache);
    final optimisticReadAt = DateTime.now().toUtc().toIso8601String();
    _markAllReadInFlight = true;

    emit(
      _applyMarkAllReadLocally(
        snapshot,
        readAt: optimisticReadAt,
        clearMarkAllReadError: true,
      ).copyWith(isMarkingAllRead: true),
    );

    try {
      await _markAllAlertsReadUseCase.execute();
      emit(
        state.copyWith(
          isMarkingAllRead: false,
          unreadCount: 0,
          clearMarkAllReadError: true,
        ),
      );
    } on Object catch (e) {
      _fullAlertsCache = fullCacheSnapshot;
      emit(_restoreMarkAllReadSnapshot(snapshot, e));
    } finally {
      _markAllReadInFlight = false;
    }
  }

  Future<void> markAsRead(String alertId) async {
    final trimmedId = alertId.trim();
    if (trimmedId.isEmpty || _markReadInFlight.contains(trimmedId)) {
      return;
    }

    final index = state.alerts.indexWhere((alert) => alert.id == trimmedId);
    if (index < 0) {
      return;
    }

    final target = state.alerts[index];
    if (target.isRead) {
      return;
    }

    final snapshot = state;
    final fullCacheSnapshot = List<InboxAlert>.from(_fullAlertsCache);
    final optimisticReadAt = DateTime.now().toUtc().toIso8601String();
    _markReadInFlight.add(trimmedId);

    emit(
      _applyMarkReadLocally(
        snapshot,
        alertId: trimmedId,
        readAt: optimisticReadAt,
        clearMarkReadError: true,
      ),
    );

    try {
      final confirmed = await _markAlertReadUseCase.execute(trimmedId);
      _fullAlertsCache = _upsertAlertInList(_fullAlertsCache, confirmed);
      emit(
        _applyMarkReadLocally(
          state,
          alertId: trimmedId,
          readAt: confirmed.readAt ?? optimisticReadAt,
          clearMarkReadError: true,
        ),
      );
    } on Object catch (e) {
      _fullAlertsCache = fullCacheSnapshot;
      emit(_restoreMarkReadSnapshot(snapshot, e));
    } finally {
      _markReadInFlight.remove(trimmedId);
    }
  }

  Future<void> _fetchAlerts({
    required bool resetPagination,
    required bool preserveReadState,
    bool preserveVisibleCount = false,
  }) async {
    try {
      final fetched = await _getAlertsUseCase.execute();
      final deduped = _dedupeByIdNewestFirst(fetched);
      final sorted = _sortNewestFirst(deduped);
      final merged = preserveReadState
          ? _mergePreservedReadState(sorted, state.alerts)
          : sorted;

      _fullAlertsCache = merged;
      final unreadCount = _countUnread(_fullAlertsCache);

      final visibleCount = _resolveVisibleCount(
        resetPagination: resetPagination,
        preserveVisibleCount: preserveVisibleCount,
        filteredTotal: _filteredAlerts().length,
      );

      _emitPagedState(
        visibleCount: visibleCount,
        unreadCount: unreadCount,
        clearError: true,
      );
    } on Object catch (e) {
      _emitFetchError(e, preserveExisting: preserveReadState || state.alerts.isNotEmpty);
    }
  }

  void _emitPagedState({
    required int visibleCount,
    int? unreadCount,
    bool clearError = false,
    bool clearMarkReadError = false,
  }) {
    final filtered = _filteredAlerts();
    final visible = filtered.take(visibleCount).toList(growable: false);
    final unread = unreadCount ?? _countUnread(_fullAlertsCache);
    final status = visible.isEmpty
        ? AlertsInboxStatus.empty
        : AlertsInboxStatus.loaded;

    emit(
      state.copyWith(
        status: status,
        alerts: visible,
        unreadCount: unread,
        hasMore: visible.length < filtered.length,
        isLoadingMore: false,
        clearError: clearError,
        clearMarkReadError: clearMarkReadError,
      ),
    );
  }

  int _resolveVisibleCount({
    required bool resetPagination,
    required bool preserveVisibleCount,
    required int filteredTotal,
  }) {
    if (filteredTotal == 0) {
      return 0;
    }
    if (resetPagination) {
      return filteredTotal < _pageSize ? filteredTotal : _pageSize;
    }
    if (preserveVisibleCount) {
      final previous = state.alerts.length;
      final baseline = previous < _pageSize ? _pageSize : previous;
      return baseline > filteredTotal ? filteredTotal : baseline;
    }
    final current = state.alerts.length;
    return current > filteredTotal ? filteredTotal : current;
  }

  List<InboxAlert> _filteredAlerts() {
    if (!state.unreadOnly) {
      return _fullAlertsCache;
    }
    return _fullAlertsCache.where((alert) => !alert.isRead).toList(growable: false);
  }

  AlertsInboxState _applyMarkReadLocally(
    AlertsInboxState base, {
    required String alertId,
    required String readAt,
    bool clearMarkReadError = false,
  }) {
    final updatedFull = _fullAlertsCache
        .map(
          (alert) => alert.id == alertId ? _withReadAt(alert, readAt) : alert,
        )
        .toList(growable: false);
    _fullAlertsCache = updatedFull;

    final updatedVisible = base.alerts
        .map(
          (alert) => alert.id == alertId ? _withReadAt(alert, readAt) : alert,
        )
        .toList(growable: false);

    final filtered = state.unreadOnly
        ? updatedVisible.where((alert) => !alert.isRead).toList(growable: false)
        : updatedVisible;

    final unreadCount = _countUnread(_fullAlertsCache);
    final status = filtered.isEmpty && state.unreadOnly
        ? AlertsInboxStatus.empty
        : base.status == AlertsInboxStatus.empty && filtered.isNotEmpty
            ? AlertsInboxStatus.loaded
            : base.status;

    return base.copyWith(
      status: status,
      alerts: filtered,
      unreadCount: unreadCount,
      hasMore: filtered.length < _filteredAlerts().length,
      clearMarkReadError: clearMarkReadError,
    );
  }

  AlertsInboxState _restoreMarkReadSnapshot(AlertsInboxState snapshot, Object error) {
    final apiError = parseApiError(error);
    final markReadError = _mapMarkReadError(apiError, error);

    return snapshot.copyWith(
      markReadErrorCode: markReadError.code,
      markReadErrorMessage: markReadError.message,
    );
  }

  AlertsInboxState _applyMarkAllReadLocally(
    AlertsInboxState base, {
    required String readAt,
    bool clearMarkAllReadError = false,
  }) {
    _fullAlertsCache = _markAllUnreadInList(_fullAlertsCache, readAt);

    final updatedVisible = _markAllUnreadInList(base.alerts, readAt);

    final filtered = state.unreadOnly
        ? updatedVisible.where((alert) => !alert.isRead).toList(growable: false)
        : updatedVisible;

    final status = filtered.isEmpty && state.unreadOnly
        ? AlertsInboxStatus.empty
        : base.status == AlertsInboxStatus.empty && filtered.isNotEmpty
            ? AlertsInboxStatus.loaded
            : base.status;

    return base.copyWith(
      status: status,
      alerts: filtered,
      unreadCount: 0,
      hasMore: filtered.length < _filteredAlerts().length,
      clearMarkAllReadError: clearMarkAllReadError,
    );
  }

  AlertsInboxState _restoreMarkAllReadSnapshot(AlertsInboxState snapshot, Object error) {
    final apiError = parseApiError(error);
    final markAllReadError = _mapMarkReadError(apiError, error);

    return snapshot.copyWith(
      isMarkingAllRead: false,
      markAllReadErrorCode: markAllReadError.code,
      markAllReadErrorMessage: markAllReadError.message,
    );
  }

  static List<InboxAlert> _markAllUnreadInList(List<InboxAlert> alerts, String readAt) {
    return alerts
        .map((alert) => alert.isRead ? alert : _withReadAt(alert, readAt))
        .toList(growable: false);
  }

  void _emitFetchError(Object e, {required bool preserveExisting}) {
    final apiError = parseApiError(e);
    final mapped = _mapFetchError(apiError, e);
    final hasVisibleAlerts = preserveExisting && state.alerts.isNotEmpty;

    emit(
      state.copyWith(
        status: hasVisibleAlerts
            ? (state.alerts.isEmpty ? AlertsInboxStatus.empty : AlertsInboxStatus.loaded)
            : AlertsInboxStatus.failure,
        errorCode: mapped.code,
        errorMessage: mapped.message,
        isLoadingMore: false,
      ),
    );
  }

  static List<InboxAlert> _dedupeByIdNewestFirst(List<InboxAlert> alerts) {
    final byId = <String, InboxAlert>{};
    for (final alert in alerts) {
      final id = alert.id.trim();
      if (id.isEmpty) {
        continue;
      }
      final existing = byId[id];
      if (existing == null || _createdAtMillis(alert) >= _createdAtMillis(existing)) {
        byId[id] = alert;
      }
    }
    return byId.values.toList(growable: false);
  }

  static List<InboxAlert> _sortNewestFirst(List<InboxAlert> alerts) {
    final copy = List<InboxAlert>.from(alerts);
    copy.sort((a, b) => _createdAtMillis(b).compareTo(_createdAtMillis(a)));
    return copy;
  }

  static int _createdAtMillis(InboxAlert alert) {
    return DateTime.tryParse(alert.createdAt)?.millisecondsSinceEpoch ?? 0;
  }

  static int _countUnread(List<InboxAlert> alerts) {
    return alerts.where((alert) => !alert.isRead).length;
  }

  static List<InboxAlert> _mergePreservedReadState(
    List<InboxAlert> fetched,
    List<InboxAlert> localAlerts, {
    bool preferSnapshotReadState = false,
  }) {
    final localReadAtById = <String, String>{};
    for (final alert in localAlerts) {
      final readAt = alert.readAt?.trim();
      if (alert.id.trim().isNotEmpty && readAt != null && readAt.isNotEmpty) {
        localReadAtById[alert.id] = readAt;
      }
    }

    return fetched
        .map((alert) {
          final preserved = localReadAtById[alert.id];
          if (preserved == null) {
            return alert;
          }
          if (preferSnapshotReadState || !alert.isRead) {
            return _withReadAt(alert, preserved);
          }
          return alert;
        })
        .toList(growable: false);
  }

  static List<InboxAlert> _upsertAlertInList(List<InboxAlert> alerts, InboxAlert updated) {
    var found = false;
    final next = alerts
        .map((alert) {
          if (alert.id == updated.id) {
            found = true;
            return updated;
          }
          return alert;
        })
        .toList(growable: false);
    if (!found) {
      next.add(updated);
    }
    return _sortNewestFirst(_dedupeByIdNewestFirst(next));
  }

  static InboxAlert _withReadAt(InboxAlert alert, String readAt) {
    return InboxAlert(
      id: alert.id,
      type: alert.type,
      severity: alert.severity,
      title: alert.title,
      message: alert.message,
      createdAt: alert.createdAt,
      readAt: readAt,
      payload: alert.payload,
    );
  }

  static _AlertsInboxMappedError _mapFetchError(ApiError apiError, Object error) {
    if (apiError.statusCode == 401 || apiError.code == AlertsInboxErrorCodes.unauthenticated) {
      return const _AlertsInboxMappedError(
        code: AlertsInboxErrorCodes.unauthenticated,
      );
    }
    if (_isNetworkError(error, apiError)) {
      return const _AlertsInboxMappedError(code: AlertsInboxErrorCodes.network);
    }
    return _AlertsInboxMappedError(
      code: apiError.code ?? AlertsInboxErrorCodes.unknown,
      message: apiError.message,
    );
  }

  static _AlertsInboxMappedError _mapMarkReadError(ApiError apiError, Object error) {
    if (apiError.statusCode == 401 || apiError.code == AlertsInboxErrorCodes.unauthenticated) {
      return const _AlertsInboxMappedError(
        code: AlertsInboxErrorCodes.unauthenticated,
      );
    }
    if (_isNetworkError(error, apiError)) {
      return const _AlertsInboxMappedError(code: AlertsInboxErrorCodes.network);
    }
    return _AlertsInboxMappedError(
      code: apiError.code ?? AlertsInboxErrorCodes.unknown,
      message: apiError.message,
    );
  }

  static bool _isNetworkError(Object error, ApiError apiError) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.sendTimeout;
    }
    return apiError.statusCode == null;
  }
}

class _AlertsInboxMappedError {
  const _AlertsInboxMappedError({
    required this.code,
    this.message,
  });

  final String code;
  final String? message;
}

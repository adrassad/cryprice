import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_error_codes.dart';

enum AlertsInboxStatus {
  initial,
  loading,
  loaded,
  refreshing,
  failure,
  empty,
}

class AlertsInboxState {
  const AlertsInboxState({
    this.status = AlertsInboxStatus.initial,
    this.alerts = const <InboxAlert>[],
    this.unreadCount = 0,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.unreadOnly = false,
    this.errorCode,
    this.errorMessage,
    this.markReadErrorCode,
    this.markReadErrorMessage,
  });

  final AlertsInboxStatus status;
  final List<InboxAlert> alerts;
  final int unreadCount;
  final bool isLoadingMore;
  final bool hasMore;

  /// When true, the feed shows unread alerts only (server list is still fully cached).
  final bool unreadOnly;
  final String? errorCode;
  final String? errorMessage;
  final String? markReadErrorCode;
  final String? markReadErrorMessage;

  bool get isInitial => status == AlertsInboxStatus.initial;

  bool get isLoading => status == AlertsInboxStatus.loading;

  bool get isRefreshing => status == AlertsInboxStatus.refreshing;

  bool get isFailure => status == AlertsInboxStatus.failure;

  bool get isEmpty => status == AlertsInboxStatus.empty;

  bool get requiresLogin => errorCode == AlertsInboxErrorCodes.unauthenticated;

  AlertsInboxState copyWith({
    AlertsInboxStatus? status,
    List<InboxAlert>? alerts,
    int? unreadCount,
    bool? isLoadingMore,
    bool? hasMore,
    bool? unreadOnly,
    String? errorCode,
    String? errorMessage,
    String? markReadErrorCode,
    String? markReadErrorMessage,
    bool clearError = false,
    bool clearMarkReadError = false,
  }) {
    return AlertsInboxState(
      status: status ?? this.status,
      alerts: alerts ?? this.alerts,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      unreadOnly: unreadOnly ?? this.unreadOnly,
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      markReadErrorCode:
          clearMarkReadError ? null : (markReadErrorCode ?? this.markReadErrorCode),
      markReadErrorMessage:
          clearMarkReadError ? null : (markReadErrorMessage ?? this.markReadErrorMessage),
    );
  }
}

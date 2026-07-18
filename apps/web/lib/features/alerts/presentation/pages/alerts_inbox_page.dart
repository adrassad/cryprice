import 'dart:async';

import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_type.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_cubit.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_error_codes.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_state.dart';
import 'package:cryprice_frontend/features/alerts/presentation/widgets/alerts_inbox_alert_tile.dart';
import 'package:cryprice_frontend/features/alerts/presentation/widgets/health_factor_alert_card.dart';
import 'package:cryprice_frontend/features/alerts/presentation/widgets/risk_news_alert_card.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Alerts inbox feed for the shell tab.
class AlertsInboxPage extends StatefulWidget {
  const AlertsInboxPage({super.key});

  @override
  State<AlertsInboxPage> createState() => _AlertsInboxPageState();
}

class _AlertsInboxPageState extends State<AlertsInboxPage> {
  final Map<String, GlobalKey> _tileKeys = <String, GlobalKey>{};
  Timer? _highlightClearTimer;

  @override
  void dispose() {
    _highlightClearTimer?.cancel();
    super.dispose();
  }

  GlobalKey _keyForAlert(String alertId) {
    return _tileKeys.putIfAbsent(alertId, GlobalKey.new);
  }

  void _scheduleHighlightClear() {
    _highlightClearTimer?.cancel();
    _highlightClearTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }
      context.read<AlertsInboxCubit>().clearHighlightedAlert();
    });
  }

  void _tryScrollToPendingAlert(AlertsInboxState state) {
    final alertId = state.pendingFocusAlertId?.trim();
    if (alertId == null || alertId.isEmpty) {
      return;
    }
    if (!state.alerts.any((alert) => alert.id == alertId)) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final targetContext = _keyForAlert(alertId).currentContext;
      if (targetContext == null) {
        return;
      }

      Scrollable.ensureVisible(
        targetContext,
        alignment: 0.25,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      context.read<AlertsInboxCubit>().markFocusScrollCompleted(alertId);
      _scheduleHighlightClear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        BlocListener<AlertsInboxCubit, AlertsInboxState>(
          listenWhen: (AlertsInboxState previous, AlertsInboxState current) =>
              previous.markReadErrorCode != current.markReadErrorCode &&
              current.markReadErrorCode != null,
          listener: (BuildContext context, AlertsInboxState state) {
            final loc = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(loc.alertsMarkReadFailed)),
            );
            context.read<AlertsInboxCubit>().clearMarkReadError();
          },
        ),
        BlocListener<AlertsInboxCubit, AlertsInboxState>(
          listenWhen: (AlertsInboxState previous, AlertsInboxState current) =>
              previous.markAllReadErrorCode != current.markAllReadErrorCode &&
              current.markAllReadErrorCode != null,
          listener: (BuildContext context, AlertsInboxState state) {
            final loc = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(loc.alertsMarkAllReadFailed)),
            );
            context.read<AlertsInboxCubit>().clearMarkAllReadError();
          },
        ),
        BlocListener<AlertsInboxCubit, AlertsInboxState>(
          listenWhen: (AlertsInboxState previous, AlertsInboxState current) {
            final pendingId = current.pendingFocusAlertId;
            if (pendingId == null || pendingId.isEmpty) {
              return false;
            }
            return previous.pendingFocusAlertId != current.pendingFocusAlertId ||
                previous.alerts != current.alerts ||
                previous.status != current.status;
          },
          listener: (BuildContext context, AlertsInboxState state) {
            _tryScrollToPendingAlert(state);
          },
        ),
      ],
      child: BlocBuilder<AlertsInboxCubit, AlertsInboxState>(
        builder: (BuildContext context, AlertsInboxState state) {
          final loc = AppLocalizations.of(context)!;

          if (state.isInitial) {
            return const SizedBox.shrink();
          }

          if (state.isLoading) {
            return Center(
              key: const Key('alerts_inbox_loading'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(loc.alertsLoading),
                ],
              ),
            );
          }

          if (state.isFailure && state.alerts.isEmpty) {
            return Center(
              key: const Key('alerts_inbox_error'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _failureMessage(loc, state),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      key: const Key('alerts_inbox_retry'),
                      onPressed: () => context.read<AlertsInboxCubit>().load(),
                      child: Text(loc.portfolioRetry),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.isEmpty) {
            return Center(
              key: const Key('alerts_inbox_empty'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  loc.alertsEmpty,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return Column(
            children: [
              if (state.isRefreshing)
                const LinearProgressIndicator(
                  key: Key('alerts_inbox_refreshing'),
                ),
              if (state.errorCode != null && state.alerts.isNotEmpty)
                _RefreshErrorBanner(
                  message: _inlineErrorMessage(loc, state),
                  onRetry: () => context.read<AlertsInboxCubit>().refresh(),
                ),
              if (_shouldShowMarkAllReadButton(state))
                _MarkAllReadButton(
                  isMarkingAllRead: state.isMarkingAllRead,
                  onPressed: state.isMarkingAllRead
                      ? null
                      : () => context.read<AlertsInboxCubit>().markAllAsRead(),
                ),
              Expanded(
                child: RefreshIndicator(
                  key: const Key('alerts_inbox_refresh'),
                  onRefresh: () => context.read<AlertsInboxCubit>().refresh(),
                  child: ListView.separated(
                    key: const Key('alerts_inbox_list'),
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: state.alerts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (BuildContext context, int index) {
                      return _buildAlertItem(
                        context,
                        loc,
                        state.alerts[index],
                        isHighlighted: state.highlightedAlertId == state.alerts[index].id,
                        tileKey: _keyForAlert(state.alerts[index].id),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAlertItem(
    BuildContext context,
    AppLocalizations loc,
    InboxAlert alert, {
    required bool isHighlighted,
    required GlobalKey tileKey,
  }) {
    final itemKey = Key('alerts_inbox_item_${alert.id}');
    final theme = Theme.of(context);
    final highlightDecoration = isHighlighted
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary,
              width: 2,
            ),
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
          )
        : null;

    Widget tileChild;
    if (alert.type == InboxAlertType.riskNews && alert.riskNewsPayload != null) {
      tileChild = RiskNewsAlertCard(
        key: itemKey,
        alert: alert,
      );
    } else if ((alert.type == InboxAlertType.healthFactorBreach ||
            alert.type == InboxAlertType.healthFactorRecovery) &&
        alert.healthFactorPayload != null) {
      tileChild = HealthFactorAlertCard(
        key: itemKey,
        alert: alert,
      );
    } else {
      tileChild = Card(
        key: itemKey,
        child: ListTile(
          title: Text(alert.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (alert.message.trim().isNotEmpty) Text(alert.message),
              Text(
                loc.alertsUnsupportedType,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          trailing: alert.isRead
              ? null
              : Icon(
                  Icons.circle,
                  size: 10,
                  color: theme.colorScheme.error,
                ),
        ),
      );
    }

    return AnimatedContainer(
      key: tileKey,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: highlightDecoration,
      padding: isHighlighted ? const EdgeInsets.all(2) : EdgeInsets.zero,
      child: AlertsInboxAlertTile(
        alert: alert,
        child: tileChild,
      ),
    );
  }

  String _failureMessage(AppLocalizations loc, AlertsInboxState state) {
    return _messageForError(loc, state.errorCode, state.errorMessage);
  }

  String _inlineErrorMessage(AppLocalizations loc, AlertsInboxState state) {
    return loc.alertsRefreshFailed;
  }

  static String _messageForError(
    AppLocalizations loc,
    String? errorCode,
    String? errorMessage,
  ) {
    return switch (errorCode) {
      AlertsInboxErrorCodes.unauthenticated => loc.loginRequired,
      AlertsInboxErrorCodes.network => loc.alertsNetworkError,
      _ => errorMessage?.trim().isNotEmpty == true
          ? errorMessage!.trim()
          : loc.alertsError,
    };
  }

  static bool _shouldShowMarkAllReadButton(AlertsInboxState state) {
    if (state.unreadCount <= 0 || state.alerts.isEmpty) {
      return false;
    }
    if (state.isInitial || state.isLoading) {
      return false;
    }
    if (state.isFailure) {
      return false;
    }
    return state.status == AlertsInboxStatus.loaded ||
        state.status == AlertsInboxStatus.refreshing;
  }
}

class _MarkAllReadButton extends StatelessWidget {
  const _MarkAllReadButton({
    required this.isMarkingAllRead,
    required this.onPressed,
  });

  final bool isMarkingAllRead;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final label = isMarkingAllRead ? loc.alertsMarkingAllRead : loc.alertsMarkAllRead;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Tooltip(
          message: loc.alertsMarkAllReadTooltip,
          child: Semantics(
            button: true,
            enabled: onPressed != null,
            label: loc.alertsMarkAllReadTooltip,
            child: TextButton.icon(
              key: const Key('alerts_inbox_mark_all_read'),
              onPressed: onPressed,
              icon: isMarkingAllRead
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : const Icon(Icons.done_all_outlined, size: 20),
              label: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

class _RefreshErrorBanner extends StatelessWidget {
  const _RefreshErrorBanner({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      key: const Key('alerts_inbox_refresh_error'),
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.error_outline, size: 20, color: colorScheme.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ),
            TextButton(
              key: const Key('alerts_inbox_refresh_retry'),
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context)!.portfolioRetry),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_type.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_cubit.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_error_codes.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_state.dart';
import 'package:cryprice_frontend/features/alerts/presentation/widgets/alerts_inbox_alert_tile.dart';
import 'package:cryprice_frontend/features/alerts/presentation/widgets/health_factor_alert_card.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Alerts inbox feed for the shell tab.
class AlertsInboxPage extends StatelessWidget {
  const AlertsInboxPage({super.key});

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
      ],
      child: BlocBuilder<AlertsInboxCubit, AlertsInboxState>(
        builder: (BuildContext context, AlertsInboxState state) {
          final loc = AppLocalizations.of(context)!;

          if (state.isLoading || state.isInitial) {
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
                      return _buildAlertItem(context, loc, state.alerts[index]);
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

  Widget _buildAlertItem(BuildContext context, AppLocalizations loc, InboxAlert alert) {
    final itemKey = Key('alerts_inbox_item_${alert.id}');

    if ((alert.type == InboxAlertType.healthFactorBreach ||
            alert.type == InboxAlertType.healthFactorRecovery) &&
        alert.healthFactorPayload != null) {
      return AlertsInboxAlertTile(
        alert: alert,
        child: HealthFactorAlertCard(
          key: itemKey,
          alert: alert,
        ),
      );
    }

    return AlertsInboxAlertTile(
      alert: alert,
      child: Card(
        key: itemKey,
        child: ListTile(
          title: Text(alert.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (alert.message.trim().isNotEmpty) Text(alert.message),
              Text(
                loc.alertsUnsupportedType,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          trailing: alert.isRead
              ? null
              : Icon(
                  Icons.circle,
                  size: 10,
                  color: Theme.of(context).colorScheme.error,
                ),
        ),
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

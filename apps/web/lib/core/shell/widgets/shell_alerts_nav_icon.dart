import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_cubit.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_state.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Notifications nav icon with reactive unread badge from [AlertsInboxCubit].
class ShellAlertsNavIcon extends StatelessWidget {
  const ShellAlertsNavIcon({
    super.key,
    this.size = 20,
    this.color,
    this.selected = false,
  });

  final double size;
  final Color? color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertsInboxCubit, AlertsInboxState>(
      buildWhen: (AlertsInboxState previous, AlertsInboxState current) =>
          previous.unreadCount != current.unreadCount,
      builder: (BuildContext context, AlertsInboxState state) {
        final icon = Icon(
          selected ? Icons.notifications : Icons.notifications_outlined,
          size: size,
          color: color,
        );
        if (state.unreadCount <= 0) {
          return icon;
        }

        final loc = AppLocalizations.of(context)!;
        final label = state.unreadCount > 99
            ? loc.alertsUnreadBadgeMax
            : '${state.unreadCount}';
        return Badge(
          key: const Key('shell_alerts_unread_badge'),
          label: Text(label),
          backgroundColor: Theme.of(context).colorScheme.error,
          child: icon,
        );
      },
    );
  }
}

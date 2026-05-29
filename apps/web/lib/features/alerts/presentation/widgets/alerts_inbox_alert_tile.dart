import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_cubit.dart';
import 'package:cryprice_frontend/features/alerts/presentation/utils/alert_copy_action.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Inbox alert wrapper: short tap marks unread alerts read; long press copies.
class AlertsInboxAlertTile extends StatelessWidget {
  const AlertsInboxAlertTile({
    super.key,
    required this.alert,
    required this.child,
    this.setClipboardData,
  });

  final InboxAlert alert;
  final Widget child;
  final AlertClipboardWriter? setClipboardData;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isUnread = !alert.isRead;

    return GestureDetector(
      key: Key('alerts_inbox_tile_${alert.id}'),
      behavior: HitTestBehavior.opaque,
      onTap: isUnread
          ? () => context.read<AlertsInboxCubit>().markAsRead(alert.id)
          : null,
      onLongPress: () => copyAlertToClipboard(
        context,
        alert,
        setClipboardData: setClipboardData,
      ),
      child: Semantics(
        button: isUnread,
        label: isUnread ? loc.alertsMarkReadHint : null,
        child: KeyedSubtree(
          key: isUnread ? Key('alerts_inbox_mark_read_${alert.id}') : null,
          child: child,
        ),
      ),
    );
  }
}

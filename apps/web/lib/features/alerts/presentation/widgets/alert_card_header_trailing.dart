import 'package:flutter/material.dart';

/// Compact header trailing area: event date and optional unread dot.
class AlertCardHeaderTrailing extends StatelessWidget {
  const AlertCardHeaderTrailing({
    super.key,
    required this.dateLabel,
    required this.dateKey,
    required this.isUnread,
    this.unreadKey,
  });

  final String dateLabel;
  final Key dateKey;
  final bool isUnread;
  final Key? unreadKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          dateLabel,
          key: dateKey,
          textAlign: TextAlign.right,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        if (isUnread)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.fiber_manual_record,
              key: unreadKey,
              size: 10,
              color: colorScheme.error,
            ),
          ),
      ],
    );
  }
}

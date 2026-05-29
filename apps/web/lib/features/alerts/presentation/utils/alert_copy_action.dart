import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/presentation/utils/alert_clipboard_formatter.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef AlertClipboardWriter = Future<void> Function(String text);

/// Copies visible alert card content to the clipboard.
Future<void> copyAlertToClipboard(
  BuildContext context,
  InboxAlert alert, {
  AlertClipboardWriter? setClipboardData,
}) async {
  final loc = AppLocalizations.of(context)!;
  final text = formatAlertClipboardText(alert, loc);
  final writer = setClipboardData ??
      (String value) => Clipboard.setData(ClipboardData(text: value));

  try {
    await writer(text);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.alertsCopiedToClipboard),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } catch (_) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.alertsCopyFailed),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

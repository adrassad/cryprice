import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_payload.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_type.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/risk_news_payload.dart';
import 'package:cryprice_frontend/features/alerts/presentation/widgets/alerts_inbox_alert_tile.dart';
import 'package:cryprice_frontend/features/alerts/presentation/widgets/risk_news_alert_card.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('long press copies visible risk_news content', (tester) async {
    String? copiedText;

    await tester.pumpWidget(
      _wrap(
        AlertsInboxAlertTile(
          alert: _riskNewsAlert(id: 'copy-long'),
          setClipboardData: (text) async {
            copiedText = text;
          },
          child: RiskNewsAlertCard(alert: _riskNewsAlert(id: 'copy-long')),
        ),
      ),
    );

    await tester.longPress(find.byKey(const Key('alerts_inbox_tile_copy-long')));
    await tester.pump();

    expect(copiedText, isNotNull);
    expect(copiedText, contains('Macro liquidity stress'));
    expect(copiedText, contains('Critical'));
    expect(copiedText, contains('Rule-based risk signal, not financial advice'));
    expect(find.text('Alert copied to clipboard'), findsOneWidget);
  });

  testWidgets('long press on read alert copies without error', (tester) async {
    String? copiedText;
    final alert = _riskNewsAlert(id: 'read-copy', readAt: '2026-05-20T11:00:00.000Z');

    await tester.pumpWidget(
      _wrap(
        AlertsInboxAlertTile(
          alert: alert,
          setClipboardData: (text) async {
            copiedText = text;
          },
          child: RiskNewsAlertCard(alert: alert),
        ),
      ),
    );

    await tester.longPress(find.byKey(const Key('alerts_inbox_tile_read-copy')));
    await tester.pump();

    expect(copiedText, contains('Macro liquidity stress'));
    expect(find.text('Alert copied to clipboard'), findsOneWidget);
  });

  testWidgets('copy failure shows error snackbar', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AlertsInboxAlertTile(
          alert: _riskNewsAlert(id: 'copy-fail'),
          setClipboardData: (_) async {
            throw Exception('clipboard unavailable');
          },
          child: RiskNewsAlertCard(alert: _riskNewsAlert(id: 'copy-fail')),
        ),
      ),
    );

    await tester.longPress(find.byKey(const Key('alerts_inbox_tile_copy-fail')));
    await tester.pump();

    expect(find.text('Could not copy alert'), findsOneWidget);
  });
}

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: ListView(children: [child])),
  );
}

InboxAlert _riskNewsAlert({
  required String id,
  String? readAt,
}) {
  return InboxAlert(
    id: id,
    type: InboxAlertType.riskNews,
    severity: 'critical',
    title: 'Macro liquidity stress',
    message: 'Market-wide funding pressure detected.',
    createdAt: '2026-05-20T10:00:00.000Z',
    readAt: readAt,
    payload: const InboxAlertRiskNewsPayload(
      RiskNewsPayload(
        targetScope: 'global',
        affectedProtocols: ['aave-v3'],
      ),
    ),
  );
}

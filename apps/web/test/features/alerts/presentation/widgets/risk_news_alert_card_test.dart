import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_payload.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_type.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/risk_news_payload.dart';
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

  testWidgets('renders global risk card with affected protocols', (tester) async {
    await tester.pumpWidget(
      _wrap(
        tester,
        _riskNewsAlert(
          id: 'global-1',
          severity: 'critical',
          targetScope: 'global',
          title: 'Macro liquidity stress',
          message: 'Market-wide funding pressure detected.',
          globalReason: 'Elevated stablecoin outflows',
          affectedProtocols: ['aave-v3'],
          primarySourceUrl: 'https://news.example.com/macro',
          primarySourceTitle: 'Macro bulletin',
        ),
        width: 800,
      ),
    );

    expect(find.text('🌍 Global DeFi Risk'), findsOneWidget);
    expect(find.text('Critical'), findsOneWidget);
    expect(find.text('Macro liquidity stress'), findsOneWidget);
    expect(find.text('aave-v3'), findsOneWidget);
    expect(find.text('Rule-based risk signal, not financial advice'), findsOneWidget);
    expect(find.byKey(const Key('risk_news_alert_source_link')), findsOneWidget);
    expect(find.byKey(const Key('risk_news_alert_exposure_block')), findsNothing);
  });

  testWidgets('renders exposure card with matched fields', (tester) async {
    await tester.pumpWidget(
      _wrap(
        tester,
        _riskNewsAlert(
          id: 'exposure-1',
          severity: 'high',
          targetScope: 'exposure',
          title: 'WBTC exposure match',
          message: 'Incident may affect your collateral.',
          matchedAssets: ['WBTC'],
          matchedProtocols: ['aave-v3'],
          matchedChains: ['ethereum'],
          matchConfidence: '0.92',
        ),
        width: 800,
      ),
    );

    expect(find.text('⚠️ Your exposure detected'), findsOneWidget);
    expect(find.byKey(const Key('risk_news_alert_exposure_block')), findsOneWidget);
    expect(find.textContaining('WBTC'), findsWidgets);
    expect(find.textContaining('0.92'), findsOneWidget);
    expect(find.text('Affected protocols'), findsNothing);
  });

  testWidgets('renders source link for valid https URL', (tester) async {
    await tester.pumpWidget(
      _wrap(
        tester,
        _riskNewsAlert(
          id: 'src-1',
          severity: 'medium',
          targetScope: 'global',
          title: 'Source test',
          message: 'Body',
          primarySourceUrl: 'https://reuters.com/defi-article',
          primarySourceTitle: 'Reuters analysis',
        ),
        width: 600,
      ),
    );

    expect(find.byKey(const Key('risk_news_alert_source_link')), findsOneWidget);
    expect(find.textContaining('Reuters analysis'), findsOneWidget);
  });

  testWidgets('shows event date in header only once', (tester) async {
    await tester.pumpWidget(
      _wrap(
        tester,
        _riskNewsAlert(
          id: 'dated-global',
          severity: 'critical',
          targetScope: 'global',
          title: 'Macro liquidity stress',
          message: 'Market-wide funding pressure detected.',
          affectedProtocols: ['aave-v3'],
        ),
        width: 800,
      ),
    );

    expect(find.byKey(const Key('risk_news_alert_header_date_dated-global')), findsOneWidget);
    expect(find.textContaining('20.05.2026'), findsOneWidget);
  });

  testWidgets('shows unavailable fallback for missing source URL', (tester) async {
    await tester.pumpWidget(
      _wrap(
        tester,
        _riskNewsAlert(
          id: 'src-missing',
          severity: 'low',
          targetScope: 'global',
          title: 'No source',
          message: 'Body',
        ),
        width: 600,
      ),
    );

    expect(find.byKey(const Key('risk_news_alert_source_unavailable')), findsOneWidget);
    expect(find.text('Source link unavailable'), findsOneWidget);
    expect(find.byKey(const Key('risk_news_alert_source_link')), findsNothing);
  });

  testWidgets('hides blocked localhost source URLs', (tester) async {
    await tester.pumpWidget(
      _wrap(
        tester,
        _riskNewsAlert(
          id: 'src-local',
          severity: 'info',
          targetScope: 'global',
          title: 'Local source',
          message: 'Body',
          primarySourceUrl: 'http://localhost:3000/internal',
        ),
        width: 600,
      ),
    );

    expect(find.byKey(const Key('risk_news_alert_source_unavailable')), findsOneWidget);
  });

  testWidgets('shows unread styling indicator', (tester) async {
    await tester.pumpWidget(
      _wrap(
        tester,
        _riskNewsAlert(
          id: 'unread-1',
          severity: 'warning',
          targetScope: 'exposure',
          title: 'Unread alert',
          message: 'Pending read',
          readAt: null,
        ),
        width: 600,
      ),
    );

    expect(find.byKey(const Key('risk_news_alert_unread_dot')), findsOneWidget);
  });

  testWidgets('long title wraps without layout overflow', (tester) async {
    final longTitle =
        'Extended DeFi risk headline covering multiple protocols chains assets and market conditions for user review';

    await tester.pumpWidget(
      _wrap(
        tester,
        _riskNewsAlert(
          id: 'long-title',
          severity: 'high',
          targetScope: 'global',
          title: longTitle,
          message: 'Summary',
        ),
        width: 320,
      ),
    );
    await tester.pump();

    expect(find.text(longTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders at narrow and wide widths', (tester) async {
    for (final width in <double>[320, 1280]) {
      await tester.pumpWidget(
        _wrap(
          tester,
          _riskNewsAlert(
            id: 'responsive-$width',
            severity: 'info',
            targetScope: 'admin_only',
            title: 'Admin alert',
            message: 'Internal signal',
          ),
          width: width,
        ),
      );
      await tester.pump();

      expect(find.text('🛠 Internal/Admin'), findsOneWidget);
      expect(find.byKey(Key('risk_news_alert_header_date_responsive-$width')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}

Widget _wrap(
  WidgetTester tester,
  InboxAlert alert, {
  required double width,
}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: MediaQuery(
      data: MediaQueryData(size: Size(width, 900)),
      child: Scaffold(
        body: ListView(
          children: [RiskNewsAlertCard(alert: alert)],
        ),
      ),
    ),
  );
}

InboxAlert _riskNewsAlert({
  required String id,
  required String severity,
  required String targetScope,
  required String title,
  required String message,
  String? readAt,
  String? globalReason,
  List<String> matchedAssets = const <String>[],
  List<String> matchedProtocols = const <String>[],
  List<String> matchedChains = const <String>[],
  String? matchConfidence,
  List<String> affectedAssets = const <String>[],
  List<String> affectedProtocols = const <String>[],
  List<String> affectedChains = const <String>[],
  String? primarySourceUrl,
  String? primarySourceTitle,
}) {
  return InboxAlert(
    id: id,
    type: InboxAlertType.riskNews,
    severity: severity,
    title: title,
    message: message,
    createdAt: '2026-05-20T10:00:00.000Z',
    readAt: readAt,
    payload: InboxAlertRiskNewsPayload(
      RiskNewsPayload(
        targetScope: targetScope,
        globalReason: globalReason,
        matchedAssets: matchedAssets,
        matchedProtocols: matchedProtocols,
        matchedChains: matchedChains,
        matchConfidence: matchConfidence,
        affectedAssets: affectedAssets,
        affectedProtocols: affectedProtocols,
        affectedChains: affectedChains,
        primarySourceUrl: primarySourceUrl,
        primarySourceTitle: primarySourceTitle,
      ),
    ),
  );
}

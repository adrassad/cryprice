import 'package:cryprice_frontend/features/alerts/data/models/inbox_alert_model.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/health_factor_alert_payload.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_payload.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_type.dart';
import 'package:cryprice_frontend/features/alerts/presentation/widgets/health_factor_alert_card.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('renders breach card with hero HF and threshold once', (tester) async {
    await tester.pumpWidget(
      _wrap(
        _hfAlert(
          id: 'breach-1',
          type: InboxAlertType.healthFactorBreach,
          severity: 'critical',
          title: 'HF below threshold',
          message: 'Health factor crossed below 1.25',
          protocol: 'aave-v3',
          walletId: '0x1234567890abcdef1234567890abcdef12345678',
          networkId: 'ethereum',
          healthFactor: '1.12',
          thresholdHf: '1.25',
        ),
        width: 800,
      ),
    );

    expect(find.textContaining('🚨'), findsWidgets);
    expect(find.text('HF breach'), findsOneWidget);
    expect(find.textContaining('Aave V3'), findsOneWidget);
    expect(find.textContaining('Ethereum'), findsOneWidget);
    expect(find.textContaining('1234'), findsWidgets);
    expect(find.textContaining('1.12'), findsWidgets);
    expect(find.textContaining('1.25'), findsWidgets);
    expect(find.byKey(const Key('health_factor_alert_hero_hf')), findsOneWidget);
    expect(find.text('Current HF'), findsNothing);
    expect(find.text('Previous HF'), findsNothing);
    expect(find.byKey(const Key('health_factor_alert_header_date_breach-1')), findsOneWidget);
  });

  testWidgets('renders realistic backend HF alert with formatted context', (tester) async {
    final alert = InboxAlertModel.fromJson(<String, Object?>{
      'id': 'realistic-1',
      'type': InboxAlertType.healthFactorBreach,
      'severity': 'warning',
      'title': 'Health Factor below threshold',
      'message': 'Aave aave HF is 1.62 (threshold 2.00, previous 1.63).',
      'previous_hf': '1.63',
      'current_hf': '1.62',
      'wallet_address': '0x31d1abcdefabcdefabcdefabcdefabcdefadc1',
      'network_id': 'arbitrum',
      'protocol': 'aave',
      'payload': <String, Object?>{
        'threshold_hf': 2.0,
        'transition': 'breach',
      },
      'created_at': '2026-05-28T19:20:00.000Z',
    }).toEntity();

    await tester.pumpWidget(
      _wrap(
        alert,
        width: 800,
      ),
    );

    expect(find.textContaining('1.62'), findsWidgets);
    expect(find.textContaining('1.63'), findsWidgets);
    expect(find.textContaining('2.00'), findsWidgets);
    expect(find.textContaining('Arbitrum'), findsOneWidget);
    expect(find.textContaining('Aave V3'), findsOneWidget);
    expect(find.text('Health Factor unavailable'), findsNothing);
    expect(find.text('Unknown'), findsNothing);
    expect(find.text('Current HF'), findsNothing);
    expect(find.textContaining('Health Factor changed'), findsNothing);
    expect(find.textContaining('Health Factor decreased'), findsOneWidget);
    expect(find.textContaining('alert threshold'), findsWidgets);
    expect(find.text('Health Factor below threshold'), findsNothing);
  });

  testWidgets('renders liquidation card without below-threshold wording', (tester) async {
    await tester.pumpWidget(
      _wrap(
        _hfAlert(
          id: 'liquidation-1',
          type: InboxAlertType.healthFactorBreach,
          severity: 'critical',
          title: 'Health Factor below threshold',
          message: 'Legacy misleading copy',
          healthFactor: '0.98',
          previousHealthFactor: '1.08',
          thresholdHf: '1.20',
        ),
        width: 800,
      ),
    );

    expect(find.textContaining('Liquidation'), findsWidgets);
    expect(
      find.textContaining('Critical situation: your position may be liquidated'),
      findsOneWidget,
    );
    expect(find.text('Health Factor below threshold'), findsNothing);
    expect(find.text('Legacy misleading copy'), findsNothing);
    expect(find.textContaining('Alert threshold'), findsOneWidget);
  });

  testWidgets('renders recovery card with movement section', (tester) async {
    await tester.pumpWidget(
      _wrap(
        _hfAlert(
          id: 'recovery-1',
          type: InboxAlertType.healthFactorRecovery,
          severity: 'info',
          title: 'HF recovered',
          message: 'Health factor recovered above threshold',
          healthFactor: '1.40',
          previousHealthFactor: '1.05',
          thresholdHf: '1.25',
        ),
        width: 800,
      ),
    );

    expect(find.text('HF recovery'), findsOneWidget);
    expect(find.textContaining('1.05'), findsOneWidget);
    expect(find.textContaining('1.40'), findsWidgets);
    expect(find.textContaining('Health Factor improved'), findsOneWidget);
    expect(find.text('Current HF'), findsNothing);
  });

  testWidgets('shortens long wallet identifiers', (tester) async {
    const fullWallet = '0x1234567890abcdef1234567890abcdef12345678';

    await tester.pumpWidget(
      _wrap(
        _hfAlert(
          id: 'wallet-long',
          type: InboxAlertType.healthFactorBreach,
          severity: 'high',
          title: 'Wallet test',
          message: 'Body',
          walletId: fullWallet,
          healthFactor: '1.10',
          thresholdHf: '1.25',
        ),
        width: 600,
      ),
    );
    await tester.pump();

    expect(find.textContaining('0x1234...5678'), findsOneWidget);
    expect(find.text(fullWallet), findsNothing);
  });

  testWidgets('omits optional context rows when fields are missing', (tester) async {
    await tester.pumpWidget(
      _wrap(
        _hfAlert(
          id: 'minimal',
          type: InboxAlertType.healthFactorBreach,
          severity: 'critical',
          title: 'Minimal HF alert',
          message: '',
          healthFactor: '0.95',
          thresholdHf: '1.25',
        ),
        width: 600,
      ),
    );

    expect(find.textContaining('Wallet:'), findsNothing);
    expect(find.textContaining('💼'), findsNothing);
    expect(find.textContaining('🌐'), findsNothing);
    expect(find.textContaining('Liquidation'), findsWidgets);
    expect(find.text('Minimal HF alert'), findsNothing);
    expect(find.text('Health Factor unavailable'), findsNothing);
  });

  testWidgets('shows unread indicator', (tester) async {
    await tester.pumpWidget(
      _wrap(
        _hfAlert(
          id: 'unread-hf',
          type: InboxAlertType.healthFactorBreach,
          severity: 'high',
          title: 'Unread',
          message: 'Pending',
          healthFactor: '1.00',
          thresholdHf: '1.25',
        ),
        width: 600,
      ),
    );

    expect(find.byKey(const Key('health_factor_alert_unread_dot')), findsOneWidget);
  });

  testWidgets('renders at narrow and wide widths without overflow', (tester) async {
    for (final width in <double>[320, 1280]) {
      await tester.pumpWidget(
        _wrap(
          _hfAlert(
            id: 'responsive-$width',
            type: InboxAlertType.healthFactorRecovery,
            severity: 'info',
            title: 'Responsive HF alert card layout check',
            message: 'Summary text',
            protocol: 'aave-v3',
            walletId: '0xabcdefabcdefabcdefabcdefabcdefabcdefabcd',
            networkId: 'ethereum',
            healthFactor: '1.55',
            previousHealthFactor: '1.10',
            thresholdHf: '1.25',
          ),
          width: width,
        ),
      );
      await tester.pump();

      expect(find.byKey(Key('health_factor_alert_card_responsive-$width')), findsOneWidget);
      expect(find.byKey(Key('health_factor_alert_header_date_responsive-$width')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}

Widget _wrap(InboxAlert alert, {required double width}) {
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
          children: [HealthFactorAlertCard(alert: alert)],
        ),
      ),
    ),
  );
}

InboxAlert _hfAlert({
  required String id,
  required String type,
  required String severity,
  required String title,
  required String message,
  String? protocol,
  String? walletId,
  String? networkId,
  String? healthFactor,
  String? thresholdHf,
  String? previousHealthFactor,
}) {
  return InboxAlert(
    id: id,
    type: type,
    severity: severity,
    title: title,
    message: message,
    createdAt: '2026-05-20T06:00:00.000Z',
    payload: InboxAlertHealthFactorPayload(
      HealthFactorAlertPayload(
        protocol: protocol,
        walletId: walletId,
        networkId: networkId,
        healthFactor: healthFactor,
        thresholdHf: thresholdHf,
        previousHealthFactor: previousHealthFactor,
      ),
    ),
  );
}

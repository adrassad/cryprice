import 'package:cryprice_frontend/features/alerts/data/models/inbox_alert_model.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/health_factor_alert_payload.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_payload.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_type.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/risk_news_payload.dart';
import 'package:cryprice_frontend/features/alerts/presentation/utils/alert_clipboard_formatter.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<AppLocalizations> loadEn() async {
    return lookupAppLocalizations(const Locale('en'));
  }

  group('formatAlertClipboardText risk_news', () {
    test('matches visible card sections including disclaimer and timestamp', () async {
      final loc = await loadEn();
      final text = formatAlertClipboardText(
        _riskNewsAlert(
          severity: 'critical',
          targetScope: 'global',
          title: 'Macro liquidity stress',
          message: 'Market-wide funding pressure detected.',
          affectedProtocols: ['aave-v3'],
          primarySourceUrl: 'https://reuters.com/defi-article',
          primarySourceTitle: 'Reuters analysis',
        ),
        loc,
      );

      expect(text, contains('Critical'));
      expect(text, contains('🌍 Global DeFi Risk'));
      expect(text, contains('Macro liquidity stress'));
      expect(text, contains('Market-wide funding pressure detected.'));
      expect(text, contains('Affected protocols\naave-v3'));
      expect(text, contains('20.05.2026'));
      expect('20.05.2026'.allMatches(text).length, 1);
      expect(text.indexOf('20.05.2026'), lessThan(text.indexOf('Macro liquidity stress')));
      expect(text, contains('Source: Reuters analysis'));
      expect(text, contains('Rule-based risk signal, not financial advice'));
      expect(text, isNot(contains('https://reuters.com')));
    });

    test('does not contain JSON or internal fields', () async {
      final loc = await loadEn();
      final text = formatAlertClipboardText(
        _riskNewsAlert(
          severity: 'high',
          targetScope: 'exposure',
          title: 'Exposure match',
          message: 'Incident summary',
          matchedAssets: ['WBTC'],
          matchConfidence: '0.92',
          primarySourceUrl: 'https://news.example.com/incident',
        ),
        loc,
      );

      expect(text, isNot(contains('{')));
      expect(text, isNot(contains('source_article_ids')));
      expect(text, isNot(contains('payload')));
      expect(text, isNot(contains('"type"')));
      expect(text, contains('Match confidence: 0.92'));
    });

    test('shows unavailable source text instead of blocked URL', () async {
      final loc = await loadEn();
      final text = formatAlertClipboardText(
        _riskNewsAlert(
          severity: 'info',
          targetScope: 'global',
          title: 'Local source',
          message: 'Body',
          primarySourceUrl: 'http://localhost:3000/internal',
        ),
        loc,
      );

      expect(text, isNot(contains('localhost')));
      expect(text, contains('Source link unavailable'));
    });

    test('exposure alert includes matched exposure lines', () async {
      final loc = await loadEn();
      final text = formatAlertClipboardText(
        _riskNewsAlert(
          severity: 'high',
          targetScope: 'exposure',
          title: 'WBTC exposure match',
          message: 'Incident may affect your collateral.',
          matchedAssets: ['WBTC'],
          matchedProtocols: ['aave-v3'],
          matchedChains: ['ethereum'],
        ),
        loc,
      );

      expect(text, contains('⚠️ Your exposure detected'));
      expect(text, contains('Matched asset: WBTC'));
      expect(text, contains('Matched protocol: aave-v3'));
      expect(text, contains('Matched chain: ethereum'));
      expect(text, isNot(contains('Affected protocols')));
    });

    test('global alert includes reason when visible', () async {
      final loc = await loadEn();
      final text = formatAlertClipboardText(
        _riskNewsAlert(
          severity: 'medium',
          targetScope: 'global',
          title: 'Macro liquidity stress',
          message: 'Market-wide funding pressure detected.',
          globalReason: 'Elevated stablecoin outflows',
        ),
        loc,
      );

      expect(text, contains('Reason'));
      expect(text, contains('Elevated stablecoin outflows'));
    });
  });

  group('formatAlertClipboardText health factor', () {
    test('matches visible HF sections and shortened wallet', () async {
      final loc = await loadEn();
      final text = formatAlertClipboardText(
        _hfAlert(
          type: InboxAlertType.healthFactorRecovery,
          severity: 'info',
          title: 'HF recovered',
          message: 'Health factor recovered above threshold',
          walletId: '0x1234567890abcdef1234567890abcdef12345678',
          protocol: 'aave-v3',
          networkId: 'ethereum',
          healthFactor: '1.40',
          previousHealthFactor: '1.05',
          thresholdHf: '1.25',
          status: 'safe',
          statusLabel: 'Safe',
        ),
        loc,
      );

      expect(text, contains('Info'));
      expect(text, contains('HF recovery'));
      expect(text, contains('Health Factor recovered'));
      expect(text, contains('Address: 0x1234...5678'));
      expect(text, contains('Ethereum · Aave V3'));
      expect(text, contains('1.40'));
      expect(text, contains('Health Factor improved'));
      expect(text, contains('1.05'));
      expect(text, contains('🎯 Alert threshold'));
      expect(text, contains('1.25'));
      expect(text, isNot(contains('Current HF')));
      expect(text, contains('20.05.2026'));
      expect('20.05.2026'.allMatches(text).length, 1);
      expect(text.indexOf('20.05.2026'), lessThan(text.indexOf('Health Factor recovered')));
    });

    test('uses top-level current_hf from realistic backend alert JSON', () async {
      final loc = await loadEn();
      final alert = InboxAlertModel.fromJson(<String, Object?>{
        'id': '1',
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

      final text = formatAlertClipboardText(alert, loc);

      expect(text, contains('1.62'));
      expect(text, contains('1.63'));
      expect(text, contains('2.00'));
      expect(text, contains('Arbitrum · Aave V3'));
      expect(text, isNot(contains('Health Factor unavailable')));
      expect(text, isNot(contains('Unknown')));
      expect(text, isNot(contains('Current HF')));
    });

    test('uses liquidation semantics for HF <= 1.00', () async {
      final loc = await loadEn();
      final alert = InboxAlertModel.fromJson(<String, Object?>{
        'id': 'liquidation-1',
        'type': InboxAlertType.healthFactorBreach,
        'severity': 'critical',
        'title': 'Health Factor below threshold',
        'message': 'Legacy misleading copy',
        'previous_hf': '1.08',
        'current_hf': '0.98',
        'wallet_address': '0x1234567890abcdef1234567890abcdef12345678',
        'network_id': 'arbitrum',
        'protocol': 'aave',
        'payload': <String, Object?>{
          'threshold_hf': 1.2,
          'transition': 'breach',
        },
        'created_at': '2026-05-28T19:20:00.000Z',
      }).toEntity();

      final text = formatAlertClipboardText(alert, loc);

      expect(text, contains('Liquidation'));
      expect(text, contains('Critical situation: your position may be liquidated'));
      expect(text, isNot(contains('Health Factor below threshold')));
      expect(text, isNot(contains('Legacy misleading copy')));
      expect(text, contains('🎯 Alert threshold'));
    });

    test('recovery movement line uses upward trend icon', () async {
      final loc = await loadEn();
      final text = formatAlertClipboardText(
        _hfAlert(
          type: InboxAlertType.healthFactorRecovery,
          severity: 'info',
          title: 'HF recovered',
          message: 'ignored',
          healthFactor: '2.30',
          previousHealthFactor: '1.90',
          thresholdHf: '2.00',
        ),
        loc,
      );

      expect(text, contains('📈 Health Factor improved'));
      expect(text, contains('Health Factor recovered above your alert threshold'));
    });

    test('shows fallback when current_hf is missing', () async {
      final loc = await loadEn();
      final text = formatAlertClipboardText(
        _hfAlert(
          type: InboxAlertType.healthFactorBreach,
          severity: 'warning',
          title: 'Missing HF',
          message: 'No structured HF values',
          thresholdHf: '1.25',
        ),
        loc,
      );

      expect(text, contains('Health Factor unavailable'));
    });
  });

  group('formatAlertClipboardText unsupported', () {
    test('falls back for unsupported alert type', () async {
      final loc = await loadEn();
      final text = formatAlertClipboardText(
        const InboxAlert(
          id: 'x1',
          type: 'legacy_alert',
          severity: 'warning',
          title: 'Legacy alert',
          message: 'Unsupported body',
          createdAt: '2026-05-20T10:00:00.000Z',
        ),
        loc,
      );

      expect(text, contains('Warning'));
      expect(text, contains('Legacy alert'));
      expect(text, contains('Unsupported alert type'));
    });
  });
}

InboxAlert _riskNewsAlert({
  required String severity,
  required String targetScope,
  required String title,
  required String message,
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
    id: 'risk-1',
    type: InboxAlertType.riskNews,
    severity: severity,
    title: title,
    message: message,
    createdAt: '2026-05-20T10:00:00.000Z',
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

InboxAlert _hfAlert({
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
  String? status,
  String? statusLabel,
}) {
  return InboxAlert(
    id: 'hf-1',
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
        status: status,
        statusLabel: statusLabel,
      ),
    ),
  );
}

import 'package:cryprice_frontend/features/alerts/data/models/inbox_alert_model.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_payload.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InboxAlertModel.fromJson', () {
    test('parses exposure risk_news payload', () {
      final alert = InboxAlertModel.fromJson(<String, Object?>{
        'id': 'alert-1',
        'type': InboxAlertType.riskNews,
        'severity': 'high',
        'title': 'Exposure',
        'message': 'Matched',
        'created_at': '2026-05-20T08:00:00.000Z',
        'payload': <String, Object?>{
          'target_scope': 'exposure',
          'matched_assets': ['WBTC'],
          'primary_source_url': 'https://example.com/article',
        },
      }).toEntity();

      expect(alert.riskNewsPayload!.isExposureScope, isTrue);
      expect(alert.riskNewsPayload!.matchedAssets, ['WBTC']);
      expect(alert.payload, isA<InboxAlertRiskNewsPayload>());
    });

    test('parses global risk_news without source URL', () {
      final alert = InboxAlertModel.fromJson(<String, Object?>{
        'id': 'alert-2',
        'type': InboxAlertType.riskNews,
        'severity': 'critical',
        'title': 'Global',
        'message': 'Macro',
        'created_at': '2026-05-20T07:00:00.000Z',
        'payload': <String, Object?>{
          'target_scope': 'global',
          'global_reason': 'Liquidity stress',
          'primary_source_url': null,
        },
      }).toEntity();

      expect(alert.riskNewsPayload!.isGlobalScope, isTrue);
      expect(alert.riskNewsPayload!.primarySourceUrl, isNull);
      expect(alert.riskNewsPayload!.globalReason, 'Liquidity stress');
    });

    test('parses health_factor_breach payload', () {
      final alert = InboxAlertModel.fromJson(<String, Object?>{
        'id': 'alert-3',
        'type': InboxAlertType.healthFactorBreach,
        'severity': 'warning',
        'title': 'Breach',
        'message': 'Below threshold',
        'created_at': '2026-05-20T06:00:00.000Z',
        'payload': <String, Object?>{
          'health_factor': '1.10',
          'threshold_hf': '1.25',
        },
      }).toEntity();

      expect(alert.healthFactorPayload!.healthFactor, '1.10');
      expect(alert.payload, isA<InboxAlertHealthFactorPayload>());
    });

    test('parses top-level current_hf and previous_hf for HF alerts', () {
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
        'read_at': null,
        'created_at': '2026-05-28T19:20:00.000Z',
      }).toEntity();

      final payload = alert.healthFactorPayload!;
      expect(payload.healthFactor, '1.62');
      expect(payload.previousHealthFactor, '1.63');
      expect(payload.thresholdHf, '2.0');
      expect(payload.walletId, '0x31d1abcdefabcdefabcdefabcdefabcdefadc1');
      expect(payload.networkId, 'arbitrum');
      expect(payload.protocol, 'aave');
      expect(payload.direction, 'breach');
    });

    test('returns null payload for unsupported alert type', () {
      final alert = InboxAlertModel.fromJson(<String, Object?>{
        'id': 'alert-4',
        'type': 'future_alert_type',
        'severity': 'info',
        'title': 'Future',
        'message': 'Not yet supported',
        'created_at': '2026-05-20T04:00:00.000Z',
        'payload': <String, Object?>{'foo': 'bar'},
      }).toEntity();

      expect(alert.payload, isNull);
      expect(alert.hasSupportedType, isFalse);
    });

    test('ignores unknown keys on alert and payload', () {
      final alert = InboxAlertModel.fromJson(<String, Object?>{
        'id': 'alert-5',
        'type': InboxAlertType.riskNews,
        'severity': 'low',
        'title': 'Risk',
        'message': 'Body',
        'created_at': '2026-05-20T03:00:00.000Z',
        'unknown_top_level': 'ignored',
        'payload': <String, Object?>{
          'target_scope': 'exposure',
          'matched_assets': ['ETH'],
          'unknown_payload_field': 42,
        },
      }).toEntity();

      expect(alert.id, 'alert-5');
      expect(alert.riskNewsPayload!.matchedAssets, ['ETH']);
    });
  });
}

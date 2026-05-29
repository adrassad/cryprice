import 'package:cryprice_frontend/features/alerts/data/models/health_factor_alert_payload_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HealthFactorAlertPayloadModel.fromAlertJson', () {
    test('prefers top-level current_hf and previous_hf over payload aliases', () {
      final model = HealthFactorAlertPayloadModel.fromAlertJson(
        <String, Object?>{
          'current_hf': '1.62',
          'previous_hf': '1.63',
          'wallet_address': '0xabc',
          'network_id': 'arbitrum',
          'protocol': 'aave',
        },
        <String, Object?>{
          'threshold_hf': 2.0,
          'transition': 'breach',
          'health_factor': '9.99',
          'previous_health_factor': '9.98',
        },
      );

      expect(model.healthFactor, '1.62');
      expect(model.previousHealthFactor, '1.63');
      expect(model.thresholdHf, '2.0');
      expect(model.walletId, '0xabc');
      expect(model.networkId, 'arbitrum');
      expect(model.protocol, 'aave');
      expect(model.direction, 'breach');
    });

    test('falls back to legacy payload-only fields', () {
      final model = HealthFactorAlertPayloadModel.fromJson(<String, Object?>{
        'health_factor': '1.12',
        'previous_health_factor': '1.05',
        'threshold_hf': '1.25',
        'wallet_id': 'wallet-1',
        'network_id': 'ethereum',
        'protocol': 'aave-v3',
        'direction': 'below',
      });

      expect(model.healthFactor, '1.12');
      expect(model.previousHealthFactor, '1.05');
      expect(model.thresholdHf, '1.25');
      expect(model.walletId, 'wallet-1');
    });
  });
}

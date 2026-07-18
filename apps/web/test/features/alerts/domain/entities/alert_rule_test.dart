import 'package:cryprice_frontend/features/alerts/data/models/alert_rule_model.dart';
import 'package:cryprice_frontend/features/alerts/data/models/alert_rules_response.dart';
import 'package:cryprice_frontend/features/alerts/data/models/create_alert_rule_request.dart';
import 'package:cryprice_frontend/features/alerts/data/models/update_alert_rule_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AlertRuleModel', () {
    test('fromJson parses decimal string threshold_hf and nullable scope ids', () {
      final rule = AlertRuleModel.fromJson(_sampleRuleJson()).toEntity();

      expect(rule.id, 'rule-1');
      expect(rule.userId, 'user-42');
      expect(rule.type, 'health_factor_threshold');
      expect(rule.protocol, 'aave');
      expect(rule.walletId, isNull);
      expect(rule.networkId, isNull);
      expect(rule.thresholdHf, '1.25');
      expect(rule.thresholdHfValue, 1.25);
      expect(rule.direction, 'below');
      expect(rule.enabled, isTrue);
      expect(rule.cooldownMinutes, 60);
      expect(rule.lastTriggeredAt, isNull);
      expect(rule.isGlobalRule, isTrue);
    });

    test('fromJson preserves non-null wallet_id and network_id', () {
      final rule = AlertRuleModel.fromJson(<String, Object?>{
        ..._sampleRuleJson(),
        'wallet_id': 'wallet-7',
        'network_id': 'network-3',
      }).toEntity();

      expect(rule.walletId, 'wallet-7');
      expect(rule.networkId, 'network-3');
      expect(rule.isGlobalRule, isFalse);
    });

    test('fromJson parses null protocol for global all-protocols rule', () {
      final rule = AlertRuleModel.fromJson(<String, Object?>{
        ..._sampleRuleJson(),
        'protocol': null,
      }).toEntity();

      expect(rule.protocol, isNull);
      expect(rule.isGlobalRule, isTrue);
    });

    test('fromJson parses camelCase aliases', () {
      final rule = AlertRuleModel.fromJson(<String, Object?>{
        'id': 'rule-2',
        'userId': 'user-1',
        'type': 'health_factor_threshold',
        'protocol': 'aave',
        'walletId': null,
        'networkId': null,
        'thresholdHf': '2.50',
        'direction': 'below',
        'enabled': false,
        'cooldownMinutes': 30,
        'lastTriggeredAt': '2026-05-20T10:00:00.000Z',
        'createdAt': '2026-05-19T10:00:00.000Z',
        'updatedAt': '2026-05-20T10:00:00.000Z',
      }).toEntity();

      expect(rule.userId, 'user-1');
      expect(rule.thresholdHf, '2.50');
      expect(rule.thresholdHfValue, 2.5);
      expect(rule.enabled, isFalse);
      expect(rule.cooldownMinutes, 30);
      expect(rule.lastTriggeredAt, '2026-05-20T10:00:00.000Z');
    });
  });

  group('AlertRulesResponse', () {
    test('fromJson parses rules list', () {
      final response = AlertRulesResponse.fromJson(<String, Object?>{
        'rules': [_sampleRuleJson()],
      });

      expect(response.rules, hasLength(1));
      expect(response.rules.single.id, 'rule-1');
    });

    test('fromJson returns empty list when rules key is missing', () {
      final response = AlertRulesResponse.fromJson(const <String, Object?>{});
      expect(response.rules, isEmpty);
    });
  });

  group('AlertRuleResponse', () {
    test('fromJson parses single rule wrapper', () {
      final response = AlertRuleResponse.fromJson(<String, Object?>{
        'rule': _sampleRuleJson(),
      });

      expect(response.rule.id, 'rule-1');
      expect(response.rule.thresholdHfValue, 1.25);
    });
  });

  group('CreateAlertRuleRequest', () {
    test('toJson serializes global health factor rule', () {
      final request = CreateAlertRuleRequest.globalHealthFactor(
        thresholdHf: '1.50',
        enabled: true,
        cooldownMinutes: 60,
      );

      expect(
        request.toJson(),
        <String, Object?>{
          'type': 'health_factor_threshold',
          'threshold_hf': '1.50',
          'direction': 'below',
          'enabled': true,
          'cooldown_minutes': 60,
          'wallet_id': null,
          'network_id': null,
        },
      );
    });
  });

  group('UpdateAlertRuleRequest', () {
    test('toJson omits null fields', () {
      final request = UpdateAlertRuleRequest(
        thresholdHf: '1.75',
        enabled: false,
      );

      expect(
        request.toJson(),
        <String, Object?>{
          'threshold_hf': '1.75',
          'enabled': false,
        },
      );
    });
  });
}

Map<String, Object?> _sampleRuleJson() {
  return <String, Object?>{
    'id': 'rule-1',
    'user_id': 'user-42',
    'type': 'health_factor_threshold',
    'protocol': 'aave',
    'wallet_id': null,
    'network_id': null,
    'threshold_hf': '1.25',
    'direction': 'below',
    'enabled': true,
    'cooldown_minutes': 60,
    'last_triggered_at': null,
    'created_at': '2026-05-19T10:00:00.000Z',
    'updated_at': '2026-05-19T10:00:00.000Z',
  };
}

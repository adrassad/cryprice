import 'package:cryprice_frontend/features/alerts/domain/entities/alert_rule.dart';

class AlertRuleModel {
  const AlertRuleModel({
    required this.id,
    required this.userId,
    required this.type,
    this.protocol,
    this.walletId,
    this.networkId,
    required this.thresholdHf,
    required this.direction,
    required this.enabled,
    required this.cooldownMinutes,
    this.lastTriggeredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String type;
  final String? protocol;
  final String? walletId;
  final String? networkId;
  final String thresholdHf;
  final String direction;
  final bool enabled;
  final int cooldownMinutes;
  final String? lastTriggeredAt;
  final String createdAt;
  final String updatedAt;

  factory AlertRuleModel.fromJson(Map<String, Object?> json) {
    String asString(Object? value) => value?.toString() ?? '';

    String? asNullableString(Object? value) {
      if (value == null) {
        return null;
      }
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    int asInt(Object? value) {
      if (value is num) {
        return value.toInt();
      }
      return int.tryParse('$value') ?? 0;
    }

    return AlertRuleModel(
      id: asString(json['id']),
      userId: asString(json['user_id'] ?? json['userId']),
      type: asString(json['type']),
      protocol: asNullableString(json['protocol']),
      walletId: asNullableString(json['wallet_id'] ?? json['walletId']),
      networkId: asNullableString(json['network_id'] ?? json['networkId']),
      thresholdHf: asString(json['threshold_hf'] ?? json['thresholdHf']),
      direction: asString(json['direction']),
      enabled: json['enabled'] == true,
      cooldownMinutes: asInt(json['cooldown_minutes'] ?? json['cooldownMinutes']),
      lastTriggeredAt: asNullableString(json['last_triggered_at'] ?? json['lastTriggeredAt']),
      createdAt: asString(json['created_at'] ?? json['createdAt']),
      updatedAt: asString(json['updated_at'] ?? json['updatedAt']),
    );
  }

  AlertRule toEntity() {
    return AlertRule(
      id: id,
      userId: userId,
      type: type,
      protocol: protocol,
      walletId: walletId,
      networkId: networkId,
      thresholdHf: thresholdHf,
      direction: direction,
      enabled: enabled,
      cooldownMinutes: cooldownMinutes,
      lastTriggeredAt: lastTriggeredAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

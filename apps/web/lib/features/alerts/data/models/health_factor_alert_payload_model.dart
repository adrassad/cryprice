import 'package:cryprice_frontend/features/alerts/domain/entities/health_factor_alert_payload.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_payload.dart';

class HealthFactorAlertPayloadModel {
  const HealthFactorAlertPayloadModel({
    this.protocol,
    this.walletId,
    this.networkId,
    this.healthFactor,
    this.thresholdHf,
    this.previousHealthFactor,
    this.direction,
    this.status,
    this.statusLabel,
  });

  final String? protocol;
  final String? walletId;
  final String? networkId;
  final String? healthFactor;
  final String? thresholdHf;
  final String? previousHealthFactor;
  final String? direction;
  final String? status;
  final String? statusLabel;

  factory HealthFactorAlertPayloadModel.fromJson(Map<String, Object?> json) {
    return HealthFactorAlertPayloadModel.fromAlertJson(const {}, json);
  }

  /// Merges top-level alert fields with nested payload for HF alerts.
  factory HealthFactorAlertPayloadModel.fromAlertJson(
    Map<String, Object?> alertJson,
    Map<String, Object?> payloadJson,
  ) {
    String? asNullableString(Object? value) {
      if (value == null) {
        return null;
      }
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    String? firstNonEmpty(Iterable<Object?> values) {
      for (final value in values) {
        final text = asNullableString(value);
        if (text != null) {
          return text;
        }
      }
      return null;
    }

    return HealthFactorAlertPayloadModel(
      protocol: firstNonEmpty([
        alertJson['protocol'],
        payloadJson['protocol'],
      ]),
      walletId: firstNonEmpty([
        alertJson['wallet_address'],
        alertJson['wallet_id'],
        alertJson['walletId'],
        payloadJson['wallet_address'],
        payloadJson['wallet_id'],
        payloadJson['walletId'],
      ]),
      networkId: firstNonEmpty([
        alertJson['network_id'],
        alertJson['networkId'],
        payloadJson['network_id'],
        payloadJson['networkId'],
      ]),
      healthFactor: firstNonEmpty([
        alertJson['current_hf'],
        alertJson['currentHf'],
        payloadJson['current_hf'],
        payloadJson['currentHf'],
        payloadJson['health_factor'],
        payloadJson['healthFactor'],
      ]),
      thresholdHf: firstNonEmpty([
        payloadJson['threshold_hf'],
        payloadJson['thresholdHf'],
        alertJson['threshold_hf'],
        alertJson['thresholdHf'],
      ]),
      previousHealthFactor: firstNonEmpty([
        alertJson['previous_hf'],
        alertJson['previousHf'],
        payloadJson['previous_hf'],
        payloadJson['previousHf'],
        payloadJson['previous_health_factor'],
        payloadJson['previousHealthFactor'],
      ]),
      direction: firstNonEmpty([
        payloadJson['transition'],
        payloadJson['direction'],
      ]),
      status: asNullableString(payloadJson['status']),
      statusLabel: asNullableString(payloadJson['status_label'] ?? payloadJson['statusLabel']),
    );
  }

  HealthFactorAlertPayload toEntity() {
    return HealthFactorAlertPayload(
      protocol: protocol,
      walletId: walletId,
      networkId: networkId,
      healthFactor: healthFactor,
      thresholdHf: thresholdHf,
      previousHealthFactor: previousHealthFactor,
      direction: direction,
      status: status,
      statusLabel: statusLabel,
    );
  }

  InboxAlertHealthFactorPayload toInboxPayload() {
    return InboxAlertHealthFactorPayload(toEntity());
  }
}

import 'package:cryprice_frontend/features/alerts/data/models/health_factor_alert_payload_model.dart';
import 'package:cryprice_frontend/features/alerts/data/models/risk_news_payload_model.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_payload.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_type.dart';

class InboxAlertModel {
  const InboxAlertModel({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    required this.createdAt,
    this.readAt,
    this.payload,
  });

  final String id;
  final String type;
  final String severity;
  final String title;
  final String message;
  final String createdAt;
  final String? readAt;
  final InboxAlertPayload? payload;

  factory InboxAlertModel.fromJson(Map<String, Object?> json) {
    String asString(Object? value) => value?.toString() ?? '';

    String? asNullableString(Object? value) {
      if (value == null) {
        return null;
      }
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    final type = asString(json['type']);
    final rawPayload = json['payload'];

    return InboxAlertModel(
      id: asString(json['id']),
      type: type,
      severity: asString(json['severity']),
      title: asString(json['title']),
      message: asString(json['message']),
      createdAt: asString(json['created_at'] ?? json['createdAt']),
      readAt: asNullableString(json['read_at'] ?? json['readAt']),
      payload: _parsePayload(type, json, rawPayload),
    );
  }

  InboxAlert toEntity() {
    return InboxAlert(
      id: id,
      type: type,
      severity: severity,
      title: title,
      message: message,
      createdAt: createdAt,
      readAt: readAt,
      payload: payload,
    );
  }

  static InboxAlertPayload? _parsePayload(
    String type,
    Map<String, Object?> alertJson,
    Object? rawPayload,
  ) {
    final map = rawPayload is Map
        ? rawPayload.cast<String, Object?>()
        : const <String, Object?>{};

    return switch (type) {
      InboxAlertType.riskNews => RiskNewsPayloadModel.fromJson(map).toInboxPayload(),
      InboxAlertType.healthFactorBreach ||
      InboxAlertType.healthFactorRecovery =>
        HealthFactorAlertPayloadModel.fromAlertJson(alertJson, map).toInboxPayload(),
      _ => null,
    };
  }
}

class AlertsListResponse {
  const AlertsListResponse({required this.alerts});

  final List<InboxAlert> alerts;

  factory AlertsListResponse.fromJson(Map<String, Object?> json) {
    final raw = json['alerts'];
    if (raw is! List) {
      return const AlertsListResponse(alerts: <InboxAlert>[]);
    }
    return AlertsListResponse(
      alerts: raw
          .whereType<Map>()
          .map((item) => InboxAlertModel.fromJson(item.cast<String, Object?>()).toEntity())
          .toList(growable: false),
    );
  }
}

class InboxAlertResponse {
  const InboxAlertResponse({required this.alert});

  final InboxAlert alert;

  factory InboxAlertResponse.fromJson(Map<String, Object?> json) {
    final raw = json['alert'];
    if (raw is Map<String, Object?>) {
      return InboxAlertResponse(alert: InboxAlertModel.fromJson(raw).toEntity());
    }
    if (raw is Map) {
      return InboxAlertResponse(
        alert: InboxAlertModel.fromJson(raw.cast<String, Object?>()).toEntity(),
      );
    }
    return InboxAlertResponse(
      alert: InboxAlertModel.fromJson(const <String, Object?>{}).toEntity(),
    );
  }
}

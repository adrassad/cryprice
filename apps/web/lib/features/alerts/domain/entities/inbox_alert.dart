import 'package:cryprice_frontend/features/alerts/domain/entities/health_factor_alert_payload.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_payload.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_type.dart';

class InboxAlert {
  const InboxAlert({
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

  bool get isRead {
    final value = readAt?.trim();
    return value != null && value.isNotEmpty;
  }

  bool get hasSupportedType => InboxAlertType.isSupported(type);

  HealthFactorAlertPayload? get healthFactorPayload {
    final payload = this.payload;
    if (payload is InboxAlertHealthFactorPayload) {
      return payload.data;
    }
    return null;
  }
}

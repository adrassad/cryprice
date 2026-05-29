import 'package:cryprice_frontend/features/alerts/domain/entities/health_factor_alert_payload.dart';

/// Typed payload attached to an [InboxAlert], parsed by alert [type].
sealed class InboxAlertPayload {
  const InboxAlertPayload();
}

final class InboxAlertHealthFactorPayload extends InboxAlertPayload {
  const InboxAlertHealthFactorPayload(this.data);

  final HealthFactorAlertPayload data;
}

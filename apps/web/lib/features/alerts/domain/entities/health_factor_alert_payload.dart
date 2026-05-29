/// Domain payload for HF breach/recovery inbox notifications.
class HealthFactorAlertPayload {
  const HealthFactorAlertPayload({
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
}

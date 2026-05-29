class UpdateAlertRuleRequest {
  const UpdateAlertRuleRequest({
    this.thresholdHf,
    this.enabled,
    this.cooldownMinutes,
    this.walletId,
    this.networkId,
  });

  final String? thresholdHf;
  final bool? enabled;
  final int? cooldownMinutes;
  final String? walletId;
  final String? networkId;

  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (thresholdHf != null) {
      json['threshold_hf'] = thresholdHf;
    }
    if (enabled != null) {
      json['enabled'] = enabled;
    }
    if (cooldownMinutes != null) {
      json['cooldown_minutes'] = cooldownMinutes;
    }
    if (walletId != null) {
      json['wallet_id'] = walletId;
    }
    if (networkId != null) {
      json['network_id'] = networkId;
    }
    return json;
  }
}

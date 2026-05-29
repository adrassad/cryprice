class CreateAlertRuleRequest {
  const CreateAlertRuleRequest({
    required this.type,
    required this.protocol,
    required this.thresholdHf,
    required this.direction,
    required this.enabled,
    required this.cooldownMinutes,
    this.walletId,
    this.networkId,
  });

  final String type;
  final String protocol;
  final String thresholdHf;
  final String direction;
  final bool enabled;
  final int cooldownMinutes;
  final String? walletId;
  final String? networkId;

  Map<String, Object?> toJson() => <String, Object?>{
        'type': type,
        'protocol': protocol,
        'threshold_hf': thresholdHf,
        'direction': direction,
        'enabled': enabled,
        'cooldown_minutes': cooldownMinutes,
        'wallet_id': walletId,
        'network_id': networkId,
      };

  /// Global Health Factor threshold rule for Aave (simple v1 mode).
  factory CreateAlertRuleRequest.globalHealthFactor({
    required String thresholdHf,
    bool enabled = true,
    int cooldownMinutes = 60,
  }) {
    return CreateAlertRuleRequest(
      type: 'health_factor_threshold',
      protocol: 'aave',
      thresholdHf: thresholdHf,
      direction: 'below',
      enabled: enabled,
      cooldownMinutes: cooldownMinutes,
      walletId: null,
      networkId: null,
    );
  }
}

class AlertRule {
  const AlertRule({
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

  /// Parsed numeric threshold for UI/domain use. Backend stores [thresholdHf] as decimal string.
  double? get thresholdHfValue => double.tryParse(thresholdHf);

  /// True when the rule applies to all wallets and networks.
  bool get isGlobalRule => walletId == null && networkId == null;
}

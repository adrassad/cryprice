class HealthFactorRisk {
  const HealthFactorRisk({
    this.ltvBps,
    this.ltv,
    this.liquidationThresholdBps,
    this.liquidationThreshold,
    this.liquidationBonusBps,
    this.liquidationPenaltyBps,
  });

  final int? ltvBps;
  final String? ltv;
  final int? liquidationThresholdBps;
  final String? liquidationThreshold;
  final int? liquidationBonusBps;
  final int? liquidationPenaltyBps;
}

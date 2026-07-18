class HealthFactorFlags {
  const HealthFactorFlags({
    this.supplyEnabled = false,
    this.borrowEnabled = false,
    this.collateralEnabled = false,
    this.isActive = false,
    this.isFrozen = false,
    this.isPaused = false,
  });

  final bool supplyEnabled;
  final bool borrowEnabled;
  final bool collateralEnabled;
  final bool isActive;
  final bool isFrozen;
  final bool isPaused;
}

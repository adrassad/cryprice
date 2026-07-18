class HealthFactorPositionBreakdown {
  const HealthFactorPositionBreakdown({
    this.assetId,
    this.address,
    this.symbol,
    this.amount,
    this.valueUsd,
    this.useAsCollateral,
    this.priceUsd,
    this.marketPriceUsd,
    this.customPriceUsd,
    this.priceSource,
  });

  final String? assetId;
  final String? address;
  final String? symbol;
  final String? amount;
  final String? valueUsd;
  final bool? useAsCollateral;
  final String? priceUsd;
  final String? marketPriceUsd;
  final String? customPriceUsd;
  final String? priceSource;
}

class HealthFactorPositionsBreakdown {
  const HealthFactorPositionsBreakdown({
    this.supplies = const <HealthFactorPositionBreakdown>[],
    this.borrows = const <HealthFactorPositionBreakdown>[],
  });

  final List<HealthFactorPositionBreakdown> supplies;
  final List<HealthFactorPositionBreakdown> borrows;
}

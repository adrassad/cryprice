class HealthFactorSupplyInput {
  const HealthFactorSupplyInput({
    this.assetId,
    this.address,
    required this.amount,
    this.useAsCollateral = true,
    this.customPriceUsd,
  });

  final String? assetId;
  final String? address;
  final String amount;
  final bool useAsCollateral;
  final String? customPriceUsd;
}

class HealthFactorBorrowInput {
  const HealthFactorBorrowInput({
    this.assetId,
    this.address,
    required this.amount,
    this.customPriceUsd,
  });

  final String? assetId;
  final String? address;
  final String amount;
  final String? customPriceUsd;
}

class HealthFactorCalculateRequest {
  const HealthFactorCalculateRequest({
    required this.protocol,
    required this.network,
    this.marketId,
    this.supplies = const <HealthFactorSupplyInput>[],
    this.borrows = const <HealthFactorBorrowInput>[],
  });

  final String protocol;
  final String network;
  final String? marketId;
  final List<HealthFactorSupplyInput> supplies;
  final List<HealthFactorBorrowInput> borrows;
}

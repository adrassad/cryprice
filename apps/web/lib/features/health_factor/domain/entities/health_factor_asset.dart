class HealthFactorAsset {
  const HealthFactorAsset({
    required this.id,
    required this.symbol,
    required this.name,
    required this.address,
    required this.decimals,
    this.logoUrl,
  });

  final String id;
  final String symbol;
  final String name;
  final String address;
  final int decimals;
  final String? logoUrl;
}

class HealthFactorPrice {
  const HealthFactorPrice({
    required this.usd,
    this.source,
    this.updatedAt,
    this.isStale = false,
  });

  final String usd;
  final String? source;
  final String? updatedAt;
  final bool isStale;
}

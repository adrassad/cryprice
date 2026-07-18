class HealthFactorNetwork {
  const HealthFactorNetwork({
    required this.id,
    required this.name,
    required this.chainId,
    this.nativeSymbol,
  });

  /// Stable string id for UI selection (from backend numeric id).
  final String id;
  final String name;
  final int chainId;
  final String? nativeSymbol;
}

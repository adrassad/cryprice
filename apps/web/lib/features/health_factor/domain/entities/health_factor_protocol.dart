class HealthFactorProtocol {
  const HealthFactorProtocol({
    required this.id,
    required this.name,
    this.version,
    this.hasReserveData = false,
  });

  final String id;
  final String name;
  final String? version;
  final bool hasReserveData;
}

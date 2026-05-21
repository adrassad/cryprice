enum PortfolioPriceStatus {
  ok,
  missing,
  stale,
  unknown;

  factory PortfolioPriceStatus.fromJson(Object? value) {
    return switch (value?.toString()) {
      'ok' => PortfolioPriceStatus.ok,
      'missing' => PortfolioPriceStatus.missing,
      'stale' => PortfolioPriceStatus.stale,
      _ => PortfolioPriceStatus.unknown,
    };
  }
}

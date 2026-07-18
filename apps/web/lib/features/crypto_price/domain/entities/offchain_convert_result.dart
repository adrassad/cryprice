/// One venue result from `POST /prices/convert/offchain`.
class OffchainVenueConvert {
  const OffchainVenueConvert({
    required this.sum,
    required this.collected,
  });

  final double sum;
  final DateTime? collected;
}

/// Backend-computed off-chain conversion for Binance and Bybit.
class OffchainConvertResult {
  const OffchainConvertResult({
    required this.coin1,
    required this.coin2,
    required this.count,
    this.binance,
    this.bybit,
  });

  final String coin1;
  final String coin2;
  final double count;
  final OffchainVenueConvert? binance;
  final OffchainVenueConvert? bybit;

  bool get hasAnyVenue => binance != null || bybit != null;
}

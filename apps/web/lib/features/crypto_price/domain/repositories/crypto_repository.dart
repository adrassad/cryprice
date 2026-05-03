import '../entities/price_fetch_outcome.dart';

abstract class CryptoRepository {
  Future<PriceFetchOutcome> getAllPrices(
    String ticker1,
    String ticker2,
    String count,
  );
}

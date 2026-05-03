import 'package:crypto_tracker_app/features/crypto_price/domain/entities/price_fetch_outcome.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/repositories/crypto_repository.dart';

class GetCryptoPriceUseCase {
  final CryptoRepository repository;
  GetCryptoPriceUseCase(this.repository);

  Future<PriceFetchOutcome> execute(
    String ticker1,
    String ticker2,
    String count,
  ) {
    return repository.getAllPrices(ticker1, ticker2, count);
  }
}

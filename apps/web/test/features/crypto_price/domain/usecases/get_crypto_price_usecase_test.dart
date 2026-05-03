import 'package:crypto_tracker_app/features/crypto_price/domain/entities/price_fetch_outcome.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/entities/price_result.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/repositories/crypto_repository.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/usecases/get_crypto_price_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRepo extends Mock implements CryptoRepository {}

PriceFetchDebugSnapshot _dummyDebug(List<PriceResult> rows) {
  return PriceFetchDebugSnapshot(
    onchainTrace: BackendPathTrace(
      path: '/prices/current/onchain/',
      isOnchainEndpoint: true,
    ),
    offchainTrace: BackendPathTrace(
      path: '/prices/current/offchain/',
      isOnchainEndpoint: false,
    ),
    mergedRowOrigins: rows.map((e) => e.origin.name).toList(),
    repositoryTotalRows: rows.length,
    cexCountAfterGroup: rows
        .where(
          (r) =>
              r.origin == PriceResultOrigin.cex || r.origin == PriceResultOrigin.crypriceOffchain,
        )
        .length,
    dexCountAfterGroup: rows.where((r) => r.origin == PriceResultOrigin.crypriceOnchain).length,
  );
}

void main() {
  late GetCryptoPriceUseCase useCase;
  late MockRepo repo;

  setUp(() {
    repo = MockRepo();
    useCase = GetCryptoPriceUseCase(repo);
  });

  test('returns PriceFetchOutcome from repository', () async {
    final priceResults = [
      const PriceResult(
        source: 'Test',
        quoteCurrency: 'usdt',
        priceType: PriceType.cex,
        status: PriceStatus.fresh,
        price: 123.45,
        symbol: 'btc',
        updatedAt: null,
        origin: PriceResultOrigin.cex,
      ),
    ];

    when(
      () => repo.getAllPrices('btc', 'usdt', '0.1'),
    ).thenAnswer(
      (_) async => PriceFetchOutcome(
        results: priceResults,
        debug: _dummyDebug(priceResults),
      ),
    );

    final result = await useCase.execute('btc', 'usdt', '0.1');

    expect(result.results, priceResults);
    expect(result.debug.cexCountAfterGroup, 1);
    expect(result.debug.dexCountAfterGroup, 0);
    verify(() => repo.getAllPrices('btc', 'usdt', '0.1')).called(1);
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/entities/price_fetch_outcome.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/entities/price_result.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/exceptions/crypto_exception.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/usecases/get_crypto_price_usecase.dart';
import 'package:crypto_tracker_app/features/crypto_price/presentation/cubit/crypto_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUseCase extends Mock implements GetCryptoPriceUseCase {}

PriceFetchDebugSnapshot _debugForCex(PriceResult sample) {
  return PriceFetchDebugSnapshot(
    onchainTrace: BackendPathTrace(
      path: '/prices/current/onchain/',
      isOnchainEndpoint: true,
    ),
    offchainTrace: BackendPathTrace(
      path: '/prices/current/offchain/',
      isOnchainEndpoint: false,
    ),
    mergedRowOrigins: [sample.origin.name],
    repositoryTotalRows: 1,
    cexCountAfterGroup: 1,
    dexCountAfterGroup: 0,
  );
}

void main() {
  late TitleCubit cubit;
  late MockUseCase useCase;

  setUp(() {
    useCase = MockUseCase();
    cubit = TitleCubit(useCase);
  });

  const sample = PriceResult(
    source: 'Test',
    quoteCurrency: 'usdt',
    priceType: PriceType.cex,
    status: PriceStatus.fresh,
    price: 50000,
    symbol: 'btc',
    updatedAt: null,
    origin: PriceResultOrigin.cex,
  );

  blocTest<TitleCubit, TitleState>(
    'emits [TitleLoading, TitleLoaded] on success',
    build: () {
      when(() => useCase.execute('btc', 'usdt', '0.1')).thenAnswer(
        (_) async => PriceFetchOutcome(
          results: const [sample],
          debug: _debugForCex(sample),
        ),
      );
      return cubit;
    },
    act: (cubit) => cubit.getPrice('btc', 'usdt', '0.1'),
    expect: () => [
      isA<TitleLoading>(),
      isA<TitleLoaded>()
          .having((s) => s.rows.length, 'row length', 1)
          .having((s) => s.countMultiplier, 'count multiplier', closeTo(0.1, 1e-9))
          .having((s) => s.userTicker1, 't1', 'btc')
          .having((s) => s.userTicker2, 't2', 'usdt'),
    ],
  );

  blocTest<TitleCubit, TitleState>(
    'emits [TitleLoading, TitleError] on CryptoException',
    build: () {
      when(
        () => useCase.execute(any(), any(), any()),
      ).thenThrow(CryptoException(CryptoErrorCode.fetchFailed));
      return cubit;
    },
    act: (cubit) => cubit.getPrice('btc', 'usdt', '0.1'),
    expect: () => [
      isA<TitleLoading>(),
      isA<TitleError>().having(
        (e) => e.errorCode,
        'code',
        'error_fetch_failed',
      ),
    ],
  );
}

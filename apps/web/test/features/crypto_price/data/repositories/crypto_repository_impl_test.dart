import 'package:cryprice_frontend/features/crypto_price/data/datasources/backend/offchain_onchain_prices_client.dart';
import 'package:cryprice_frontend/features/crypto_price/data/repositories/crypto_repository_impl.dart';
import 'package:cryprice_frontend/features/crypto_price/domain/entities/offchain_convert_result.dart';
import 'package:cryprice_frontend/features/crypto_price/domain/entities/price_fetch_outcome.dart';
import 'package:cryprice_frontend/features/crypto_price/domain/entities/price_result.dart';
import 'package:cryprice_frontend/features/crypto_price/domain/exceptions/crypto_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

const _kOn = '/prices/current/onchain/btc';
const _kConvert = '/prices/convert/offchain';

class _MockBackend extends Mock implements OffchainOnchainPricesClient {}

BackendPathTrace _trace(String path, bool on) => BackendPathTrace(
      path: path,
      isOnchainEndpoint: on,
      httpAttempted: true,
      statusCode: 200,
      rawDataRuntimeType: 'Map',
    );

TracedPriceRows _emptyTraced(String path, bool on) =>
    TracedPriceRows(<PriceResult>[], _trace(path, on));

OffchainConvertResult _sampleConvert({
  String coin1 = 'BTC',
  String coin2 = 'USDT',
  double count = 1,
}) {
  return OffchainConvertResult(
    coin1: coin1,
    coin2: coin2,
    count: count,
    binance: const OffchainVenueConvert(
      sum: 78392,
      collected: null,
    ),
    bybit: const OffchainVenueConvert(
      sum: 78300,
      collected: null,
    ),
  );
}

void _stubConvert(
  _MockBackend backend, {
  OffchainConvertResult? result,
}) {
  when(
    () => backend.fetchOffchainConvertTraced(
      coin1: any(named: 'coin1'),
      coin2: any(named: 'coin2'),
      count: any(named: 'count'),
    ),
  ).thenAnswer(
    (_) async => (
      result: result,
      trace: _trace(_kConvert, false),
    ),
  );
}

void main() {
  late _MockBackend backend;

  setUpAll(() {
    registerFallbackValue('');
    registerFallbackValue(0.0);
  });

  setUp(() {
    backend = _MockBackend();
  });

  test('returns offchain convert and on-chain dex rows', () async {
    _stubConvert(
      backend,
      result: _sampleConvert(coin1: 'BTC', coin2: 'U'),
    );
    when(() => backend.fetchOnchainTraced('btc', 'u', '1')).thenAnswer(
      (_) async => TracedPriceRows(
        [
          const PriceResult(
            source: 'CRYPRICE',
            symbol: 'btc',
            network: 'eth',
            quoteCurrency: 'u',
            price: 2,
            priceType: PriceType.onchain,
            status: PriceStatus.fresh,
            updatedAt: null,
            origin: PriceResultOrigin.crypriceOnchain,
          ),
        ],
        _trace(_kOn, true),
      ),
    );
    when(() => backend.fetchOnchainTraced('u', 'btc', '1')).thenAnswer(
      (_) async => _emptyTraced('/prices/current/onchain/u', true),
    );

    final repo = CryptoRepositoryImpl(backend: backend);
    final r = await repo.getAllPrices('btc', 'u', '1');
    expect(r.offchainConvert, isNotNull);
    expect(r.offchainConvert!.binance?.sum, 78392);
    expect(r.results, hasLength(1));
    expect(r.results.single.origin, PriceResultOrigin.crypriceOnchain);
    expect(r.debug.cexCountAfterGroup, 2);
  });

  test('returns when only off-chain convert is available', () async {
    _stubConvert(
      backend,
      result: _sampleConvert(coin1: 'BTC', coin2: 'U'),
    );
    when(() => backend.fetchOnchainTraced('btc', 'u', '1')).thenAnswer(
      (_) async => _emptyTraced(_kOn, true),
    );
    when(() => backend.fetchOnchainTraced('u', 'btc', '1')).thenAnswer(
      (_) async => _emptyTraced('/prices/current/onchain/u', true),
    );

    final repo = CryptoRepositoryImpl(backend: backend);
    final r = await repo.getAllPrices('btc', 'u', '1');
    expect(r.results, isEmpty);
    expect(r.offchainConvert?.hasAnyVenue, isTrue);
  });

  test('stable-first pair uses crypto asset for onchain path', () async {
    _stubConvert(
      backend,
      result: _sampleConvert(coin1: 'USDT', coin2: 'BTC'),
    );
    when(
      () => backend.fetchOnchainTraced('BTC', 'USDT', '1'),
    ).thenAnswer((_) async => _emptyTraced(_kOn, true));

    final repo = CryptoRepositoryImpl(backend: backend);
    final r = await repo.getAllPrices('USDT', 'BTC', '1');
    expect(r.offchainConvert?.coin1, 'USDT');
    verify(() => backend.fetchOnchainTraced('BTC', 'USDT', '1')).called(1);
    verifyNever(() => backend.fetchOffchainTraced(any(), any(), any()));
  });

  test('dual onchain fetch for two non-stable assets', () async {
    _stubConvert(
      backend,
      result: _sampleConvert(coin1: 'BTC', coin2: 'WBTC'),
    );
    when(() => backend.fetchOnchainTraced('BTC', 'WBTC', '1')).thenAnswer(
      (_) async => _emptyTraced('/onchain/btc', true),
    );
    when(() => backend.fetchOnchainTraced('WBTC', 'BTC', '1')).thenAnswer(
      (_) async => _emptyTraced('/onchain/wbtc', true),
    );

    final repo = CryptoRepositoryImpl(backend: backend);
    final r = await repo.getAllPrices('BTC', 'WBTC', '1');
    expect(r.offchainConvert?.coin2, 'WBTC');
    verify(() => backend.fetchOnchainTraced('BTC', 'WBTC', '1')).called(1);
    verify(() => backend.fetchOnchainTraced('WBTC', 'BTC', '1')).called(1);
    verifyNever(() => backend.fetchOffchainTraced(any(), any(), any()));
  });

  test('throws when convert and onchain are both empty', () async {
    _stubConvert(backend, result: null);
    when(() => backend.fetchOnchainTraced('a', 'b', '1')).thenAnswer(
      (_) async => _emptyTraced('/prices/current/onchain/a', true),
    );
    when(() => backend.fetchOnchainTraced('b', 'a', '1')).thenAnswer(
      (_) async => _emptyTraced('/prices/current/onchain/b', true),
    );

    final repo = CryptoRepositoryImpl(backend: backend);
    expect(
      () => repo.getAllPrices('a', 'b', '1'),
      throwsA(isA<CryptoException>()),
    );
  });
}

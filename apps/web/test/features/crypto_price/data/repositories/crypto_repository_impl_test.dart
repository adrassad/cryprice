import 'package:crypto_tracker_app/features/crypto_price/data/datasources/backend/offchain_onchain_prices_client.dart';
import 'package:crypto_tracker_app/features/crypto_price/data/repositories/crypto_repository_impl.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/entities/price_fetch_outcome.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/entities/price_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

const _kOff = '/prices/current/offchain/btc';
const _kOn = '/prices/current/onchain/btc';

class _MockBackend extends Mock implements OffchainOnchainPricesClient {}

BackendPathTrace _trace(String path, bool on) => BackendPathTrace(
      path: path,
      isOnchainEndpoint: on,
      httpAttempted: true,
      statusCode: 200,
      rawDataRuntimeType: 'Map',
    );

void main() {
  late _MockBackend backend;

  setUp(() {
    backend = _MockBackend();
  });

  test('merges off-chain then on-chain rows from backend only', () async {
    when(() => backend.fetchOffchainTraced('btc', 'u', '1')).thenAnswer(
      (_) async => TracedPriceRows(
        [
          const PriceResult(
            source: 'CRYPRICE (off-chain)',
            symbol: 'btc',
            quoteCurrency: 'u',
            price: 1,
            priceType: PriceType.offchain,
            status: PriceStatus.fresh,
            updatedAt: null,
            origin: PriceResultOrigin.crypriceOffchain,
          ),
        ],
        _trace(_kOff, false),
      ),
    );
    when(() => backend.fetchOffchainTraced('u', 'btc', '1')).thenAnswer(
      (_) async => TracedPriceRows(<PriceResult>[], _trace(_kOff, false)),
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
      (_) async => TracedPriceRows(<PriceResult>[], _trace(_kOn, true)),
    );

    final repo = CryptoRepositoryImpl(backend: backend);
    final r = await repo.getAllPrices('btc', 'u', '1');
    expect(r.results, hasLength(2));
    expect(r.results[0].origin, PriceResultOrigin.crypriceOffchain);
    expect(r.results[0].price, 1);
    expect(r.results[1].origin, PriceResultOrigin.crypriceOnchain);
    expect(r.results[1].price, 2);
  });

  test('returns when only off-chain backend has a row', () async {
    when(
      () => backend.fetchOffchainTraced('btc', 'u', '1'),
    ).thenAnswer(
      (_) async => TracedPriceRows(
        [
          const PriceResult(
            source: 'CRYPRICE (off-chain)',
            symbol: 'btc',
            quoteCurrency: 'u',
            price: 42,
            priceType: PriceType.offchain,
            status: PriceStatus.fresh,
            updatedAt: null,
            origin: PriceResultOrigin.crypriceOffchain,
          ),
        ],
        _trace(_kOff, false),
      ),
    );
    when(
      () => backend.fetchOffchainTraced('u', 'btc', '1'),
    ).thenAnswer((_) async => TracedPriceRows(<PriceResult>[], _trace(_kOff, false)));
    when(
      () => backend.fetchOnchainTraced('btc', 'u', '1'),
    ).thenAnswer((_) async => TracedPriceRows(<PriceResult>[], _trace(_kOn, true)));
    when(
      () => backend.fetchOnchainTraced('u', 'btc', '1'),
    ).thenAnswer((_) async => TracedPriceRows(<PriceResult>[], _trace(_kOn, true)));

    final repo = CryptoRepositoryImpl(backend: backend);
    final r = await repo.getAllPrices('btc', 'u', '1');
    expect(r.results, hasLength(1));
    expect(r.results.first.origin, PriceResultOrigin.crypriceOffchain);
    expect(r.results.first.price, 42);
  });

  test('off-chain rows match when user tickers are reversed (USDT then BTC)', () async {
    when(
      () => backend.fetchOffchainTraced('BTC', 'USDT', '1'),
    ).thenAnswer(
      (_) async => TracedPriceRows(
        [
          const PriceResult(
            source: 'CRYPRICE · binance',
            symbol: 'BTC',
            quoteCurrency: 'BTCUSDT',
            price: 78392,
            priceType: PriceType.offchain,
            status: PriceStatus.fresh,
            updatedAt: null,
            origin: PriceResultOrigin.crypriceOffchain,
          ),
        ],
        _trace(_kOff, false),
      ),
    );
    when(
      () => backend.fetchOnchainTraced('BTC', 'USDT', '1'),
    ).thenAnswer((_) async => TracedPriceRows(<PriceResult>[], _trace(_kOn, true)));

    final repo = CryptoRepositoryImpl(backend: backend);
    final r = await repo.getAllPrices('USDT', 'BTC', '1');
    expect(r.results, hasLength(1));
    expect(r.results.single.price, 78392);
    verify(() => backend.fetchOffchainTraced('BTC', 'USDT', '1')).called(1);
    verify(() => backend.fetchOnchainTraced('BTC', 'USDT', '1')).called(1);
  });

  test('crypriceOffchain rows are limited to the user-selected trading pair', () async {
    when(
      () => backend.fetchOffchainTraced('BTC', 'USDT', '1'),
    ).thenAnswer(
      (_) async => TracedPriceRows(
        [
          const PriceResult(
            source: 'CRYPRICE · binance',
            symbol: 'BTC',
            quoteCurrency: 'BTCUSDT',
            price: 1,
            priceType: PriceType.offchain,
            status: PriceStatus.fresh,
            updatedAt: null,
            origin: PriceResultOrigin.crypriceOffchain,
          ),
          const PriceResult(
            source: 'CRYPRICE · binance',
            symbol: 'BTC',
            quoteCurrency: 'BTCBUSD',
            price: 2,
            priceType: PriceType.offchain,
            status: PriceStatus.fresh,
            updatedAt: null,
            origin: PriceResultOrigin.crypriceOffchain,
          ),
        ],
        _trace(_kOff, false),
      ),
    );
    when(
      () => backend.fetchOnchainTraced('BTC', 'USDT', '1'),
    ).thenAnswer((_) async => TracedPriceRows(<PriceResult>[], _trace(_kOn, true)));

    final repo = CryptoRepositoryImpl(backend: backend);
    final r = await repo.getAllPrices('BTC', 'USDT', '1');
    expect(r.results, hasLength(1));
    expect(r.results.single.quoteCurrency, 'BTCUSDT');
    expect(r.results.single.price, 1);
  });

  test('CoinGecko off-chain rows match canonical slug only, not CEX pair logic', () async {
    when(
      () => backend.fetchOffchainTraced('BTC', 'USDT', '1'),
    ).thenAnswer(
      (_) async => TracedPriceRows(
        [
          const PriceResult(
            source: 'CRYPRICE · coingecko',
            symbol: 'BTC',
            network: 'coingecko',
            quoteCurrency: 'batcat',
            price: 1,
            priceType: PriceType.offchain,
            status: PriceStatus.fresh,
            updatedAt: null,
            origin: PriceResultOrigin.crypriceOffchain,
          ),
          const PriceResult(
            source: 'CRYPRICE · coingecko',
            symbol: 'BTC',
            network: 'coingecko',
            quoteCurrency: 'bitcoin',
            price: 78392,
            priceType: PriceType.offchain,
            status: PriceStatus.fresh,
            updatedAt: null,
            origin: PriceResultOrigin.crypriceOffchain,
          ),
          const PriceResult(
            source: 'CRYPRICE · coingecko',
            symbol: 'BTC',
            network: 'coingecko',
            quoteCurrency: 'bitcoin-ai-2',
            price: 3,
            priceType: PriceType.offchain,
            status: PriceStatus.fresh,
            updatedAt: null,
            origin: PriceResultOrigin.crypriceOffchain,
          ),
        ],
        _trace(_kOff, false),
      ),
    );
    when(
      () => backend.fetchOnchainTraced('BTC', 'USDT', '1'),
    ).thenAnswer((_) async => TracedPriceRows(<PriceResult>[], _trace(_kOn, true)));

    final repo = CryptoRepositoryImpl(backend: backend);
    final r = await repo.getAllPrices('BTC', 'USDT', '1');
    expect(r.results, hasLength(1));
    expect(r.results.single.quoteCurrency, 'bitcoin');
    expect(r.results.single.price, 78392);
  });

  test('CoinGecko rows dropped when base symbol has no canonical slug mapping', () async {
    when(
      () => backend.fetchOffchainTraced('DOGE', 'USDT', '1'),
    ).thenAnswer(
      (_) async => TracedPriceRows(
        [
          const PriceResult(
            source: 'CRYPRICE · coingecko',
            symbol: 'DOGE',
            network: 'coingecko',
            quoteCurrency: 'dogecoin',
            price: 0.1,
            priceType: PriceType.offchain,
            status: PriceStatus.fresh,
            updatedAt: null,
            origin: PriceResultOrigin.crypriceOffchain,
          ),
        ],
        _trace(_kOff, false),
      ),
    );
    when(
      () => backend.fetchOnchainTraced('DOGE', 'USDT', '1'),
    ).thenAnswer((_) async => TracedPriceRows(<PriceResult>[], _trace(_kOn, true)));

    final repo = CryptoRepositoryImpl(backend: backend);
    final r = await repo.getAllPrices('DOGE', 'USDT', '1');
    expect(r.results, isEmpty);
  });

  test(
    'dedupes identical rows when merging dual off-chain fetches (two non-stable assets)',
    () async {
      const shared = PriceResult(
        source: 'CRYPRICE · binance',
        network: 'binance',
        symbol: 'BTC',
        quoteCurrency: 'BTCBUSD',
        price: 100,
        priceType: PriceType.offchain,
        status: PriceStatus.fresh,
        updatedAt: null,
        origin: PriceResultOrigin.crypriceOffchain,
      );
      when(() => backend.fetchOffchainTraced('BTC', 'WBTC', '1')).thenAnswer(
        (_) async => TracedPriceRows([shared], _trace('/offchain/btc', false)),
      );
      when(() => backend.fetchOffchainTraced('WBTC', 'BTC', '1')).thenAnswer(
        (_) async => TracedPriceRows([shared], _trace('/offchain/wbtc', false)),
      );
      when(() => backend.fetchOnchainTraced('BTC', 'WBTC', '1')).thenAnswer(
        (_) async =>
            TracedPriceRows(<PriceResult>[], _trace('/onchain/btc', true)),
      );
      when(() => backend.fetchOnchainTraced('WBTC', 'BTC', '1')).thenAnswer(
        (_) async =>
            TracedPriceRows(<PriceResult>[], _trace('/onchain/wbtc', true)),
      );

      final repo = CryptoRepositoryImpl(backend: backend);
      final r = await repo.getAllPrices('BTC', 'WBTC', '1');
      expect(r.results, hasLength(1));
      expect(r.results.single.quoteCurrency, 'BTCBUSD');
      verify(() => backend.fetchOffchainTraced('BTC', 'WBTC', '1')).called(1);
      verify(() => backend.fetchOffchainTraced('WBTC', 'BTC', '1')).called(1);
    },
  );

  test('returns empty results and debug when both backend calls yield no rows', () async {
    when(
      () => backend.fetchOffchainTraced('a', 'b', '1'),
    ).thenAnswer(
      (_) async => TracedPriceRows(
        <PriceResult>[],
        _trace('/prices/current/offchain/a', false),
      ),
    );
    when(
      () => backend.fetchOffchainTraced('b', 'a', '1'),
    ).thenAnswer(
      (_) async => TracedPriceRows(
        <PriceResult>[],
        _trace('/prices/current/offchain/b', false),
      ),
    );
    when(
      () => backend.fetchOnchainTraced('a', 'b', '1'),
    ).thenAnswer(
      (_) async => TracedPriceRows(
        <PriceResult>[],
        _trace('/prices/current/onchain/a', true),
      ),
    );
    when(
      () => backend.fetchOnchainTraced('b', 'a', '1'),
    ).thenAnswer(
      (_) async => TracedPriceRows(
        <PriceResult>[],
        _trace('/prices/current/onchain/b', true),
      ),
    );

    final repo = CryptoRepositoryImpl(backend: backend);
    final r = await repo.getAllPrices('a', 'b', '1');
    expect(r.results, isEmpty);
    expect(r.debug.repositoryTotalRows, 0);
  });
}

import 'package:crypto_tracker_app/features/crypto_price/domain/conversion/user_pair_conversion_result.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/conversion/user_pair_quote_converter.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/entities/price_result.dart';
import 'package:test/test.dart';

PriceResult _cexRow({
  required String symbol,
  required String quote,
  required double price,
  String network = 'binance',
  String source = 'CRYPRICE · binance',
}) {
  return PriceResult(
    source: source,
    network: network,
    symbol: symbol,
    quoteCurrency: quote,
    price: price,
    priceType: PriceType.offchain,
    status: PriceStatus.fresh,
    origin: PriceResultOrigin.crypriceOffchain,
  );
}

PriceResult _coingeckoRow({
  required String symbol,
  required String slug,
  required double price,
}) {
  return PriceResult(
    source: 'CRYPRICE · coingecko',
    network: 'coingecko',
    symbol: symbol,
    quoteCurrency: slug,
    price: price,
    priceType: PriceType.offchain,
    status: PriceStatus.fresh,
    origin: PriceResultOrigin.crypriceOffchain,
  );
}

PriceResult _dexRow({
  required String symbol,
  required String network,
  required double price,
}) {
  return PriceResult(
    source: 'CRYPRICE',
    symbol: symbol,
    network: network,
    quoteCurrency: 'usd',
    price: price,
    priceType: PriceType.onchain,
    status: PriceStatus.fresh,
    origin: PriceResultOrigin.crypriceOnchain,
  );
}

UserPairConversionResult? _compute(
  List<PriceResult> section,
  PriceResult anchor, {
  required String u1,
  required String u2,
  double count = 1,
}) {
  return UserPairQuoteConverter.compute(
    sectionRows: section,
    anchorRow: anchor,
    userCoin1: u1,
    userCoin2: u2,
    count: count,
  );
}

void main() {
  group('CEX pair (Binance/Bybit style)', () {
    test('cexDirect: BTC then USDT', () {
      final r = _cexRow(symbol: 'BTC', quote: 'BTCUSDT', price: 78392);
      final s = _compute([r], r, u1: 'BTC', u2: 'USDT', count: 0.1);
      expect(s, isNotNull);
      expect(s!.amount, closeTo(7839.2, 1e-6));
      expect(s.currencyLabel, 'USDT');
      expect(s.mode, UserPairConversionMode.cexDirect);
    });

    test('cexInverse: USDT then BTC', () {
      final r = _cexRow(symbol: 'BTC', quote: 'BTCUSDT', price: 78392);
      final s = _compute([r], r, u1: 'USDT', u2: 'BTC', count: 1);
      expect(s, isNotNull);
      expect(s!.amount, closeTo(1 / 78392, 1e-12));
      expect(s.currencyLabel, 'BTC');
      expect(s.mode, UserPairConversionMode.cexInverse);
    });

    test('cexCross: BTC vs WBTC same provider USDT', () {
      final btc = _cexRow(symbol: 'BTC', quote: 'BTCUSDT', price: 79055.33);
      final wbtc = _cexRow(symbol: 'WBTC', quote: 'WBTCUSDT', price: 78843.89);
      final section = [btc, wbtc];
      final s = _compute(section, btc, u1: 'BTC', u2: 'WBTC', count: 1);
      expect(s, isNotNull);
      expect(s!.mode, UserPairConversionMode.cexCross);
      expect(s.amount, closeTo(79055.33 / 78843.89, 1e-6));
      expect(s.currencyLabel, 'WBTC');
    });

    test('cexCross: null when quote legs mismatch across assets', () {
      final btcBusd = _cexRow(symbol: 'BTC', quote: 'BTCBUSD', price: 79000);
      final wbtcUsdt = _cexRow(symbol: 'WBTC', quote: 'WBTCUSDT', price: 78800);
      final s = _compute([btcBusd, wbtcUsdt], btcBusd, u1: 'BTC', u2: 'WBTC');
      expect(s, isNull);
    });

    test('cexCross: null when same venue but different provider source', () {
      final a = _cexRow(
        symbol: 'BTC',
        quote: 'BTCUSDT',
        price: 79000,
        source: 'CRYPRICE · binance',
      );
      final b = _cexRow(
        symbol: 'WBTC',
        quote: 'WBTCUSDT',
        price: 78800,
        source: 'CRYPRICE · bybit',
      );
      expect(_compute([a, b], a, u1: 'BTC', u2: 'WBTC'), isNull);
    });
  });

  group('CoinGecko slug USD', () {
    test('coingeckoDirect: BTC -> USDT', () {
      final r = _coingeckoRow(symbol: 'BTC', slug: 'bitcoin', price: 78392);
      final s = _compute([r], r, u1: 'BTC', u2: 'USDT', count: 0.1);
      expect(s, isNotNull);
      expect(s!.mode, UserPairConversionMode.coingeckoDirect);
      expect(s.amount, closeTo(7839.2, 1e-6));
      expect(s.currencyLabel, 'USDT');
    });

    test('coingeckoInverse: USDT -> BTC', () {
      final r = _coingeckoRow(symbol: 'BTC', slug: 'bitcoin', price: 78392);
      final s = _compute([r], r, u1: 'USDT', u2: 'BTC', count: 1);
      expect(s, isNotNull);
      expect(s!.mode, UserPairConversionMode.coingeckoInverse);
      expect(s.amount, closeTo(1 / 78392, 1e-12));
      expect(s.currencyLabel, 'BTC');
    });

    test('coingeckoCross: BTC vs WBTC', () {
      final btc = _coingeckoRow(symbol: 'BTC', slug: 'bitcoin', price: 80000);
      final wbtc = _coingeckoRow(symbol: 'WBTC', slug: 'wrapped-bitcoin', price: 79000);
      final section = [btc, wbtc];
      final s = _compute(section, btc, u1: 'BTC', u2: 'WBTC', count: 1);
      expect(s, isNotNull);
      expect(s!.mode, UserPairConversionMode.coingeckoCross);
      expect(s.amount, closeTo(80000 / 79000, 1e-6));
    });

    test('no guess: unknown ticker has no CoinGecko cross', () {
      final btc = _coingeckoRow(symbol: 'BTC', slug: 'bitcoin', price: 80000);
      final section = [btc];
      expect(_compute(section, btc, u1: 'BTC', u2: 'BTC.b'), isNull);
    });
  });

  group('DEX on-chain USD', () {
    test('dexUsdDirect: WBTC -> USDC', () {
      final r = _dexRow(symbol: 'WBTC', network: 'arbitrum', price: 78046.97);
      final s = _compute([r], r, u1: 'WBTC', u2: 'USDC', count: 0.1);
      expect(s, isNotNull);
      expect(s!.mode, UserPairConversionMode.dexUsdDirect);
      expect(s.amount, closeTo(7804.697, 1e-3));
    });

    test('dexUsdInverse: USDT -> WBTC', () {
      final r = _dexRow(symbol: 'WBTC', network: 'arbitrum', price: 78046.97);
      final s = _compute([r], r, u1: 'USDT', u2: 'WBTC', count: 1);
      expect(s, isNotNull);
      expect(s!.mode, UserPairConversionMode.dexUsdInverse);
      expect(s.amount, closeTo(1 / 78046.97, 1e-12));
      expect(s.currencyLabel, 'WBTC');
    });

    test('dexCross: BTC vs WBTC same network', () {
      final btc = _dexRow(symbol: 'BTC', network: 'arbitrum', price: 80000);
      final wbtc = _dexRow(symbol: 'WBTC', network: 'arbitrum', price: 79000);
      final s = _compute([btc, wbtc], btc, u1: 'BTC', u2: 'WBTC');
      expect(s, isNotNull);
      expect(s!.mode, UserPairConversionMode.dexCross);
      expect(s.amount, closeTo(80000 / 79000, 1e-6));
    });
  });

  test('null when price is zero', () {
    final r = _cexRow(symbol: 'BTC', quote: 'USDT', price: 0);
    expect(_compute([r], r, u1: 'BTC', u2: 'USDT'), isNull);
  });

  test('both crypto: no fake fallback on single CEX row when cross impossible', () {
    final r = _cexRow(symbol: 'BTC', quote: 'BTCUSDT', price: 78392);
    expect(_compute([r], r, u1: 'BTC', u2: 'WBTC'), isNull);
  });
}

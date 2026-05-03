import 'dart:convert';

import 'package:crypto_tracker_app/features/crypto_price/data/models/current_price_dto.dart';
import 'package:crypto_tracker_app/features/crypto_price/domain/entities/price_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseOffchainBackendResponse: venue -> list of rows (off-chain API contract)', () {
    final raw = {
      'binance': [
        {
          'source': 'binance',
          'token': 'WBTC',
          'pair': 'WBTCUSDT',
          'price_usd': 77823.05,
          'calculated_at': '2026-04-22T09:15:00.130Z',
          'updated_at': '2026-04-22T09:15:01.304Z',
        },
      ],
      'bybit': [
        {
          'source': 'bybit',
          'token': 'WBTC',
          'pair': 'WBTCUSDT',
          'price_usd': 77791.252623,
          'updated_at': '2026-04-22T09:15:01.978Z',
        },
      ],
    };
    final list = parseOffchainBackendResponse(raw);
    expect(list, hasLength(2));
    expect(list[0].symbol, 'WBTC');
    expect(list[0].quote, 'WBTCUSDT');
    expect(list[0].network, 'binance');
    expect(list[0].sourceLabel, 'binance');
    expect(list[0].price, closeTo(77823.05, 0.01));
    expect(list[1].network, 'bybit');
    expect(list[1].sourceLabel, 'bybit');
  });

  test('parseOffchainBackendResponse: nested data list', () {
    const raw = {
    'data': [
      {
        'symbol': 'WETH',
        'price': '1.1',
        'chain': 'eth',
      },
    ],
  };
    final list = parseOffchainBackendResponse(raw);
    expect(list, hasLength(1));
    expect(list.first.symbol, 'WETH');
    expect(list.first.network, isNotNull);
  });

  test('toPriceResult maps to offchain and fills symbol from user from', () {
    const dto = CurrentPriceItemDto(
      symbol: null,
      network: 'arbitrum',
      tokenAddress: '0x1234567890abcdef',
      quote: 'USDT',
      price: 2.0,
    );
    final r = dto.toPriceResult(
      'eth',
      'usdt',
      priceType: PriceType.offchain,
      origin: PriceResultOrigin.crypriceOffchain,
    );
    expect(r.symbol, 'eth');
    expect(r.network, 'arbitrum');
    expect(r.price, 2.0);
    expect(r.origin, PriceResultOrigin.crypriceOffchain);
  });

  test('parseOnchainPerNetworkMap: one row per key, null entries skipped', () {
    final raw = {
      'arbitrum': {
        'price_usd': 77851.67598832,
        'symbol': 'WBTC',
        'collected_at': '2026-04-22T07:24:59.000Z',
      },
      'avalanche': null,
      'base': null,
      'ethereum': {
        'price_usd': 77790.82848945,
        'symbol': 'WBTC',
        'collected_at': '2026-04-22T07:24:59.000Z',
      },
    };
    final list = parseOnchainPerNetworkMap(raw);
    expect(list, hasLength(2));
    expect(list.map((e) => e.network).toList(), ['arbitrum', 'ethereum']);
    expect(list[0].symbol, 'WBTC');
    expect(list[0].price, closeTo(77851.67598832, 0.0001));
    expect(list[0].quote, 'usd');
    expect(list[0].updatedAt, isNotNull);
    expect(list[1].price, closeTo(77790.82848945, 0.0001));

    for (final d in list) {
      final r = d.toPriceResult(
        'eth',
        'usdt',
        priceType: PriceType.onchain,
        origin: PriceResultOrigin.crypriceOnchain,
      );
      expect(r.origin, PriceResultOrigin.crypriceOnchain);
      expect(r.source, 'CRYPRICE');
    }
  });

  test('parseOnchainPerNetworkMap: error envelope yields no rows (not fatal)', () {
    expect(
      parseOnchainPerNetworkMap(<String, dynamic>{'error': 'Price not found'}),
      isEmpty,
    );
    expect(
      parseOnchainPerNetworkMap(<String, dynamic>{'error': 'Price not found', 'code': 404}),
      isEmpty,
    );
  });

  test('parseOnchainPerNetworkMap: same result from JSON String (Dio string body)', () {
    final raw = {
      'arbitrum': {
        'price_usd': 77851.67598832,
        'symbol': 'WBTC',
        'collected_at': '2026-04-22T07:24:59.000Z',
      },
      'avalanche': null,
      'base': null,
      'ethereum': {
        'price_usd': 77790.82848945,
        'symbol': 'WBTC',
        'collected_at': '2026-04-22T07:24:59.000Z',
      },
    };
    final fromString = parseOnchainPerNetworkMap(jsonEncode(raw));
    expect(fromString, hasLength(2));
    expect(fromString.map((e) => e.network).toList(), ['arbitrum', 'ethereum']);
  });

  test('parseOnchainPerNetworkMap: unwraps {"data": { ... network map ... }}', () {
    final inner = {
      'arbitrum': {
        'price_usd': 77851.67598832,
        'symbol': 'WBTC',
        'collected_at': '2026-04-22T07:24:59.000Z',
      },
      'avalanche': null,
      'ethereum': {
        'price_usd': 77790.82848945,
        'symbol': 'WBTC',
        'collected_at': '2026-04-22T07:24:59.000Z',
      },
    };
    final wrapped = parseOnchainPerNetworkMap(<String, dynamic>{'data': inner});
    expect(wrapped, hasLength(2));
    expect(wrapped.map((e) => e.network).toList(), ['arbitrum', 'ethereum']);
  });
}

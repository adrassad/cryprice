import 'package:cryprice_frontend/features/crypto_price/data/models/offchain_convert_dto.dart';
import 'package:test/test.dart';

void main() {
  test('fromDynamic parses per-venue convert response', () {
    final dto = OffchainConvertDto.fromDynamic({
      'coin1': 'BTC',
      'coin2': 'AVAX',
      'count': 0.12,
      'binance': {
        'sum': 1108.85234567,
        'collected': '2026-06-07T12:30:00.22+02:00',
      },
      'bybit': null,
    });
    expect(dto, isNotNull);
    expect(dto!.coin1, 'BTC');
    expect(dto.coin2, 'AVAX');
    expect(dto.count, 0.12);
    expect(dto.binance?.sum, closeTo(1108.85234567, 1e-6));
    expect(dto.binance?.collected, isNotNull);
    expect(dto.bybit, isNull);

    final entity = dto.toEntity();
    expect(entity.hasAnyVenue, isTrue);
    expect(entity.binance, isNotNull);
    expect(entity.bybit, isNull);
  });

  test('fromDynamic rejects invalid count', () {
    expect(
      OffchainConvertDto.fromDynamic({
        'coin1': 'BTC',
        'coin2': 'AVAX',
        'count': 0,
      }),
      isNull,
    );
  });
}

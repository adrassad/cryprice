import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_position_breakdown_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses flat breakdown with valueUsd and price fields', () {
    final model = HealthFactorPositionBreakdownModel.fromJson(<String, Object?>{
      'assetId': '10',
      'symbol': 'WETH',
      'amount': '1.5',
      'valueUsd': '5250',
      'priceUsd': '3500',
      'marketPriceUsd': '3400',
      'customPriceUsd': '3500',
      'priceSource': 'custom',
    });

    final entity = model.toEntity();
    expect(entity.assetId, '10');
    expect(entity.valueUsd, '5250');
    expect(entity.priceUsd, '3500');
    expect(entity.marketPriceUsd, '3400');
    expect(entity.customPriceUsd, '3500');
    expect(entity.priceSource, 'custom');
  });

  test('maps legacy usd field to valueUsd', () {
    final model = HealthFactorPositionBreakdownModel.fromJson(<String, Object?>{
      'assetId': '10',
      'usd': '100',
    });

    expect(model.toEntity().valueUsd, '100');
  });

  test('parses nested asset object', () {
    final model = HealthFactorPositionBreakdownModel.fromJson(<String, Object?>{
      'asset': <String, Object?>{
        'id': 103,
        'symbol': 'USDC',
        'address': '0xusdc',
      },
      'amount': '2500',
      'valueUsd': '2375',
      'priceUsd': '0.95',
      'marketPriceUsd': '1',
      'customPriceUsd': '0.95',
      'priceSource': 'custom',
    });

    final entity = model.toEntity();
    expect(entity.assetId, '103');
    expect(entity.symbol, 'USDC');
    expect(entity.address, '0xusdc');
    expect(entity.priceSource, 'custom');
  });
}

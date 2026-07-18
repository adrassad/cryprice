import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_calculate_request_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_calculate_response_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_markets_response_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_network_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_protocol_model.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_calculate_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('HealthFactorProtocolModel maps to entity', () {
    const model = HealthFactorProtocolModel(
      id: 'aave_v3',
      name: 'Aave V3',
      version: '3',
      hasReserveData: true,
    );

    final entity = model.toEntity();

    expect(entity.id, 'aave_v3');
    expect(entity.name, 'Aave V3');
    expect(entity.version, '3');
    expect(entity.hasReserveData, isTrue);
  });

  test('HealthFactorNetworkModel maps id to string entity id', () {
    const model = HealthFactorNetworkModel(
      id: 2,
      name: 'arbitrum',
      chainId: 42161,
      nativeSymbol: 'ETH',
    );

    final entity = model.toEntity();

    expect(entity.id, '2');
    expect(entity.name, 'arbitrum');
    expect(entity.chainId, 42161);
    expect(entity.nativeSymbol, 'ETH');
  });

  test('HealthFactorMarketsResponseModel maps nested reserve fields', () {
    final model = HealthFactorMarketsResponseModel.fromJson(<String, Object?>{
      'market': <String, Object?>{
        'protocol': 'aave_v3',
        'network': <String, Object?>{
          'id': 2,
          'name': 'arbitrum',
          'chainId': 42161,
        },
        'marketId': null,
        'reserves': [
          <String, Object?>{
            'protocol': 'aave_v3',
            'network': <String, Object?>{
              'id': 2,
              'name': 'arbitrum',
              'chainId': 42161,
            },
            'marketId': null,
            'asset': <String, Object?>{
              'id': 10,
              'symbol': 'WETH',
              'name': 'WETH',
              'address': '0xabc',
              'decimals': 18,
            },
            'price': <String, Object?>{
              'usd': '3500.5',
              'source': 'aave_oracle',
              'isStale': false,
            },
            'risk': <String, Object?>{
              'ltvBps': 8000,
              'ltv': '0.8000',
            },
            'flags': <String, Object?>{
              'supplyEnabled': true,
              'borrowEnabled': true,
              'collateralEnabled': true,
              'isActive': true,
              'isFrozen': false,
              'isPaused': false,
            },
            'warnings': <Object?>['STALE_PRICE'],
          },
        ],
      },
    });

    final entity = model.toEntity();

    expect(entity.protocol, 'aave_v3');
    expect(entity.network.id, '2');
    expect(entity.reserves.single.asset.id, '10');
    expect(entity.reserves.single.price.usd, '3500.5');
    expect(entity.reserves.single.risk.ltv, '0.8000');
    expect(entity.reserves.single.flags.collateralEnabled, isTrue);
    expect(entity.reserves.single.warnings.single.raw, 'STALE_PRICE');
  });

  test('HealthFactorCalculateResponseModel maps totals, positions, warnings', () {
    final model = HealthFactorCalculateResponseModel.fromJson(<String, Object?>{
      'calculation': <String, Object?>{
        'protocol': 'aave_v3',
        'network': <String, Object?>{
          'id': 2,
          'name': 'arbitrum',
          'chainId': 42161,
        },
        'healthFactor': '1.7325',
        'healthFactorDisplay': '1.73',
        'isInfinite': false,
        'riskLevel': 'high',
        'totals': <String, Object?>{
          'collateralUsd': '5250',
          'collateralWeightedUsd': '4331.25',
          'borrowUsd': '2500',
        },
        'positions': <String, Object?>{
          'supplies': [
            <String, Object?>{
              'assetId': '10',
              'amount': '1.5',
              'valueUsd': '5250',
              'useAsCollateral': true,
              'priceUsd': '3500',
              'marketPriceUsd': '3400',
              'customPriceUsd': '3500',
              'priceSource': 'custom',
            },
          ],
          'borrows': <Object?>[],
        },
        'warnings': [
          <String, Object?>{
            'code': 'PRICE_STALE',
            'message': 'Stale USDC',
          },
        ],
      },
    });

    final entity = model.toEntity();

    expect(entity.healthFactor, '1.7325');
    expect(entity.healthFactorDisplay, '1.73');
    expect(entity.totals.borrowUsd, '2500');
    expect(entity.riskLevel, 'high');
    expect(entity.positions.supplies.single.amount, '1.5');
    expect(entity.positions.supplies.single.valueUsd, '5250');
    expect(entity.positions.supplies.single.priceUsd, '3500');
    expect(entity.positions.supplies.single.marketPriceUsd, '3400');
    expect(entity.positions.supplies.single.customPriceUsd, '3500');
    expect(entity.positions.supplies.single.priceSource, 'custom');
    expect(entity.warnings.single.code, 'PRICE_STALE');
  });

  test('HealthFactorCalculateResponseModel parses nested asset breakdown', () {
    final model = HealthFactorCalculateResponseModel.fromJson(<String, Object?>{
      'calculation': <String, Object?>{
        'healthFactorDisplay': '1.50',
        'isInfinite': false,
        'riskLevel': 'moderate',
        'totals': <String, Object?>{
          'collateralUsd': '100',
          'collateralWeightedUsd': '80',
          'borrowUsd': '50',
        },
        'positions': <String, Object?>{
          'supplies': [
            <String, Object?>{
              'asset': <String, Object?>{
                'id': 103,
                'symbol': 'WETH',
                'address': '0xabc',
                'decimals': 18,
              },
              'amount': '1',
              'valueUsd': '3500',
              'priceUsd': '2500',
              'marketPriceUsd': '3500',
              'customPriceUsd': '2500',
              'priceSource': 'custom',
              'useAsCollateral': true,
            },
          ],
          'borrows': <Object?>[],
        },
      },
    });

    final row = model.toEntity().positions.supplies.single;
    expect(row.assetId, '103');
    expect(row.symbol, 'WETH');
    expect(row.address, '0xabc');
    expect(row.valueUsd, '3500');
    expect(row.priceUsd, '2500');
    expect(row.priceSource, 'custom');
  });

  test('HealthFactorCalculateRequestModel.fromEntity maps customPriceUsd', () {
    const entity = HealthFactorCalculateRequest(
      protocol: 'aave_v3',
      network: 'arbitrum',
      supplies: [
        HealthFactorSupplyInput(
          assetId: '10',
          amount: '1',
          customPriceUsd: '99.5',
        ),
      ],
      borrows: [
        HealthFactorBorrowInput(
          assetId: '11',
          amount: '2',
          customPriceUsd: '0.5',
        ),
      ],
    );

    final json = HealthFactorCalculateRequestModel.fromEntity(entity).toJson();
    final supply = (json['supplies']! as List).single as Map<String, Object?>;
    expect(supply['customPriceUsd'], '99.5');
    final borrow = (json['borrows']! as List).single as Map<String, Object?>;
    expect(borrow['customPriceUsd'], '0.5');
  });

  test('HealthFactorCalculateResponseModel maps null healthFactor when infinite', () {
    final model = HealthFactorCalculateResponseModel.fromCalculationJson(
      <String, Object?>{
        'healthFactor': null,
        'healthFactorDisplay': '∞',
        'isInfinite': true,
        'riskLevel': 'safe',
        'totals': <String, Object?>{
          'collateralUsd': '0',
          'collateralWeightedUsd': '0',
          'borrowUsd': '0',
        },
        'positions': <String, Object?>{},
      },
    );

    final entity = model.toEntity();

    expect(entity.healthFactor, isNull);
    expect(entity.isInfinite, isTrue);
    expect(entity.healthFactorDisplay, '∞');
  });

  test('HealthFactorCalculateRequestModel.fromEntity omits userId', () {
    const entity = HealthFactorCalculateRequest(
      protocol: 'aave_v3',
      network: 'arbitrum',
      supplies: [
        HealthFactorSupplyInput(assetId: '10', amount: '100'),
      ],
      borrows: [
        HealthFactorBorrowInput(assetId: '11', amount: '50'),
      ],
    );

    final json = HealthFactorCalculateRequestModel.fromEntity(entity).toJson();

    expect(json.containsKey('userId'), isFalse);
    expect(json.containsKey('user_id'), isFalse);
    expect(json['network'], 'arbitrum');
    expect((json['supplies']! as List).single, isA<Map<String, Object?>>());
  });
}

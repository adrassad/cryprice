import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_calculate_response_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_markets_response_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_network_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_protocol_model.dart';
import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_warning_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HealthFactorProtocolModel', () {
    test('listFromResponse parses protocols', () {
      final list = HealthFactorProtocolModel.listFromResponse(<String, Object?>{
        'protocols': [
          <String, Object?>{
            'id': 'aave_v3',
            'name': 'Aave V3',
            'version': '3',
            'hasReserveData': true,
          },
        ],
      });

      expect(list, hasLength(1));
      expect(list.single.id, 'aave_v3');
      expect(list.single.name, 'Aave V3');
      expect(list.single.version, '3');
      expect(list.single.hasReserveData, isTrue);
    });
  });

  group('HealthFactorNetworkModel', () {
    test('listFromResponse parses networks', () {
      final list = HealthFactorNetworkModel.listFromResponse(<String, Object?>{
        'protocol': 'aave_v3',
        'networks': [
          <String, Object?>{
            'id': 2,
            'name': 'arbitrum',
            'chainId': 42161,
            'nativeSymbol': 'ETH',
          },
        ],
      });

      expect(list.single.id, 2);
      expect(list.single.name, 'arbitrum');
      expect(list.single.chainId, 42161);
      expect(list.single.nativeSymbol, 'ETH');
    });
  });

  group('HealthFactorMarketsResponseModel', () {
    test('parses nested asset, price, risk, and flags', () {
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
                'logoUrl': null,
              },
              'price': <String, Object?>{
                'usd': '3500.5',
                'source': 'aave_oracle',
                'updatedAt': '2026-06-03T11:55:00.000Z',
                'isStale': false,
              },
              'risk': <String, Object?>{
                'ltvBps': 8000,
                'ltv': '0.8000',
                'liquidationThresholdBps': 8250,
                'liquidationThreshold': '0.8250',
                'liquidationBonusBps': 10500,
                'liquidationPenaltyBps': null,
              },
              'flags': <String, Object?>{
                'supplyEnabled': true,
                'borrowEnabled': true,
                'collateralEnabled': true,
                'isActive': true,
                'isFrozen': false,
                'isPaused': false,
              },
              'syncedAt': '2026-06-03T12:00:00.000Z',
              'warnings': <Object?>[],
            },
          ],
        },
      });

      expect(model.protocol, 'aave_v3');
      expect(model.network.name, 'arbitrum');
      expect(model.reserves, hasLength(1));

      final reserve = model.reserves.single;
      expect(reserve.asset.id, '10');
      expect(reserve.asset.symbol, 'WETH');
      expect(reserve.price.usd, '3500.5');
      expect(reserve.risk.ltv, '0.8000');
      expect(reserve.risk.ltvBps, 8000);
      expect(reserve.flags.collateralEnabled, isTrue);
    });
  });

  group('HealthFactorWarningModel', () {
    test('parses string warning', () {
      final warning = HealthFactorWarningModel.fromJson('PRICE_STALE');
      expect(warning.message, 'PRICE_STALE');
      expect(warning.raw, 'PRICE_STALE');
    });

    test('parses structured warning', () {
      final warning = HealthFactorWarningModel.fromJson(<String, Object?>{
        'code': 'PRICE_STALE',
        'message': 'USDC price is stale',
      });
      expect(warning.code, 'PRICE_STALE');
      expect(warning.message, 'USDC price is stale');
    });
  });

  group('HealthFactorCalculateResponseModel', () {
    test('parses calculation totals and HF strings', () {
      final model = HealthFactorCalculateResponseModel.fromJson(<String, Object?>{
        'calculation': <String, Object?>{
          'protocol': 'aave_v3',
          'network': <String, Object?>{
            'id': 2,
            'name': 'arbitrum',
            'chainId': 42161,
          },
          'marketId': null,
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
            'supplies': <Object?>[],
            'borrows': <Object?>[],
          },
          'warnings': <Object?>[],
          'computedAt': '2026-06-03T12:00:00.000Z',
        },
      });

      expect(model.healthFactor, '1.7325');
      expect(model.healthFactorDisplay, '1.73');
      expect(model.totals.collateralUsd, '5250');
      expect(model.totals.borrowUsd, '2500');
      expect(model.riskLevel, 'high');
      expect(model.isInfinite, isFalse);
    });

    test('allows null healthFactor when infinite', () {
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

      expect(model.healthFactor, isNull);
      expect(model.isInfinite, isTrue);
      expect(model.healthFactorDisplay, '∞');
    });
  });
}

import 'package:cryprice_frontend/features/health_factor/data/models/health_factor_calculate_request_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toJson keeps amount as string', () {
    final json = const HealthFactorCalculateRequestModel(
      network: 'arbitrum',
      supplies: [
        HealthFactorSupplyInputModel(
          assetId: '10',
          amount: '1000.5',
          useAsCollateral: true,
        ),
      ],
      borrows: [
        HealthFactorBorrowInputModel(
          assetId: '11',
          amount: '500',
        ),
      ],
    ).toJson();

    final supplies = json['supplies']! as List<Object?>;
    final supply = supplies.single as Map<String, Object?>;
    expect(supply['amount'], '1000.5');
    expect(supply['amount'], isA<String>());

    final borrows = json['borrows']! as List<Object?>;
    final borrow = borrows.single as Map<String, Object?>;
    expect(borrow['amount'], '500');
  });

  test('toJson includes assetId and address fallback', () {
    final withAssetId = const HealthFactorCalculateRequestModel(
      network: 'arbitrum',
      supplies: [
        HealthFactorSupplyInputModel(assetId: '10', amount: '1'),
      ],
      borrows: [],
    ).toJson();
    final supplyAsset = (withAssetId['supplies']! as List).single as Map<String, Object?>;
    expect(supplyAsset['assetId'], '10');
    expect(supplyAsset.containsKey('address'), isFalse);

    final withAddress = const HealthFactorCalculateRequestModel(
      network: 'arbitrum',
      supplies: [],
      borrows: [
        HealthFactorBorrowInputModel(
          address: '0xborrow',
          amount: '2',
        ),
      ],
    ).toJson();
    final borrowAddress = (withAddress['borrows']! as List).single as Map<String, Object?>;
    expect(borrowAddress['address'], '0xborrow');
    expect(borrowAddress.containsKey('assetId'), isFalse);
  });

  test('toJson omits null marketId', () {
    final json = const HealthFactorCalculateRequestModel(
      network: 'arbitrum',
    ).toJson();

    expect(json.containsKey('marketId'), isFalse);
    expect(json['network'], 'arbitrum');
  });

  test('toJson includes marketId when set', () {
    final json = const HealthFactorCalculateRequestModel(
      network: 'arbitrum',
      marketId: 'market-1',
    ).toJson();

    expect(json['marketId'], 'market-1');
  });

  test('toJson includes customPriceUsd on supply and borrow when set', () {
    final json = const HealthFactorCalculateRequestModel(
      network: 'arbitrum',
      supplies: [
        HealthFactorSupplyInputModel(
          assetId: '103',
          amount: '1.5',
          customPriceUsd: '2500',
        ),
      ],
      borrows: [
        HealthFactorBorrowInputModel(
          assetId: '111',
          amount: '2500',
          customPriceUsd: '0.95',
        ),
      ],
    ).toJson();

    final supply = (json['supplies']! as List).single as Map<String, Object?>;
    expect(supply['customPriceUsd'], '2500');
    expect(supply['customPriceUsd'], isA<String>());

    final borrow = (json['borrows']! as List).single as Map<String, Object?>;
    expect(borrow['customPriceUsd'], '0.95');
  });

  test('toJson omits customPriceUsd when null or empty', () {
    final json = const HealthFactorCalculateRequestModel(
      network: 'arbitrum',
      supplies: [
        HealthFactorSupplyInputModel(
          assetId: '10',
          amount: '1',
          customPriceUsd: null,
        ),
        HealthFactorSupplyInputModel(
          assetId: '11',
          amount: '2',
          customPriceUsd: '   ',
        ),
      ],
      borrows: [
        HealthFactorBorrowInputModel(assetId: '12', amount: '3'),
      ],
    ).toJson();

    for (final row in json['supplies']! as List) {
      final map = row as Map<String, Object?>;
      expect(map.containsKey('customPriceUsd'), isFalse);
    }
    final borrow = (json['borrows']! as List).single as Map<String, Object?>;
    expect(borrow.containsKey('customPriceUsd'), isFalse);
  });

  test('toJson never includes userId or user_id', () {
    final json = const HealthFactorCalculateRequestModel(
      network: 'arbitrum',
      supplies: [
        HealthFactorSupplyInputModel(assetId: '10', amount: '1'),
      ],
      borrows: [
        HealthFactorBorrowInputModel(assetId: '11', amount: '1'),
      ],
    ).toJson();

    expect(json.containsKey('userId'), isFalse);
    expect(json.containsKey('user_id'), isFalse);

    for (final row in json['supplies']! as List) {
      final map = row as Map<String, Object?>;
      expect(map.containsKey('userId'), isFalse);
      expect(map.containsKey('user_id'), isFalse);
    }
    for (final row in json['borrows']! as List) {
      final map = row as Map<String, Object?>;
      expect(map.containsKey('userId'), isFalse);
      expect(map.containsKey('user_id'), isFalse);
    }
  });
}

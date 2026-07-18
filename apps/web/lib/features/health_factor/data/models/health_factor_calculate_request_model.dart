import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_calculate_request.dart';

class HealthFactorSupplyInputModel {
  const HealthFactorSupplyInputModel({
    this.assetId,
    this.address,
    required this.amount,
    this.useAsCollateral = true,
    this.customPriceUsd,
  }) : assert(
          assetId != null || address != null,
          'Supply row requires assetId or address',
        );

  final String? assetId;
  final String? address;
  final String amount;
  final bool useAsCollateral;
  final String? customPriceUsd;

  Map<String, Object?> toJson() {
    final map = <String, Object?>{
      'amount': amount,
      'useAsCollateral': useAsCollateral,
    };
    final id = assetId?.trim();
    if (id != null && id.isNotEmpty) {
      map['assetId'] = id;
    }
    final addr = address?.trim();
    if (addr != null && addr.isNotEmpty) {
      map['address'] = addr;
    }
    final customPrice = customPriceUsd?.trim();
    if (customPrice != null && customPrice.isNotEmpty) {
      map['customPriceUsd'] = customPrice;
    }
    return map;
  }

  factory HealthFactorSupplyInputModel.fromEntity(HealthFactorSupplyInput entity) {
    return HealthFactorSupplyInputModel(
      assetId: entity.assetId,
      address: entity.address,
      amount: entity.amount,
      useAsCollateral: entity.useAsCollateral,
      customPriceUsd: entity.customPriceUsd,
    );
  }
}

class HealthFactorBorrowInputModel {
  const HealthFactorBorrowInputModel({
    this.assetId,
    this.address,
    required this.amount,
    this.customPriceUsd,
  }) : assert(
          assetId != null || address != null,
          'Borrow row requires assetId or address',
        );

  final String? assetId;
  final String? address;
  final String amount;
  final String? customPriceUsd;

  Map<String, Object?> toJson() {
    final map = <String, Object?>{
      'amount': amount,
    };
    final id = assetId?.trim();
    if (id != null && id.isNotEmpty) {
      map['assetId'] = id;
    }
    final addr = address?.trim();
    if (addr != null && addr.isNotEmpty) {
      map['address'] = addr;
    }
    final customPrice = customPriceUsd?.trim();
    if (customPrice != null && customPrice.isNotEmpty) {
      map['customPriceUsd'] = customPrice;
    }
    return map;
  }

  factory HealthFactorBorrowInputModel.fromEntity(HealthFactorBorrowInput entity) {
    return HealthFactorBorrowInputModel(
      assetId: entity.assetId,
      address: entity.address,
      amount: entity.amount,
      customPriceUsd: entity.customPriceUsd,
    );
  }
}

class HealthFactorCalculateRequestModel {
  const HealthFactorCalculateRequestModel({
    required this.network,
    this.marketId,
    this.supplies = const <HealthFactorSupplyInputModel>[],
    this.borrows = const <HealthFactorBorrowInputModel>[],
  });

  final String network;
  final String? marketId;
  final List<HealthFactorSupplyInputModel> supplies;
  final List<HealthFactorBorrowInputModel> borrows;

  Map<String, Object?> toJson() {
    final map = <String, Object?>{
      'network': network.trim(),
      'supplies': supplies.map((row) => row.toJson()).toList(growable: false),
      'borrows': borrows.map((row) => row.toJson()).toList(growable: false),
    };
    final market = marketId?.trim();
    if (market != null && market.isNotEmpty) {
      map['marketId'] = market;
    }
    return map;
  }

  factory HealthFactorCalculateRequestModel.fromEntity(
    HealthFactorCalculateRequest entity,
  ) {
    return HealthFactorCalculateRequestModel(
      network: entity.network,
      marketId: entity.marketId,
      supplies: entity.supplies
          .map(HealthFactorSupplyInputModel.fromEntity)
          .toList(growable: false),
      borrows: entity.borrows
          .map(HealthFactorBorrowInputModel.fromEntity)
          .toList(growable: false),
    );
  }
}

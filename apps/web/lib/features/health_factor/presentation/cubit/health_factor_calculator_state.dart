import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_calculate_result.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_market_reserve.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_markets_result.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_network.dart';
import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_protocol.dart';

/// Client-side validation error when calculate is invoked with an empty form.
const String kHealthFactorCalculatorInvalidFormCode = 'INVALID_FORM';

/// Client-side validation when custom price mode is on but price is empty.
const String kHealthFactorCalculatorInvalidFormCustomPriceCode =
    'INVALID_FORM_CUSTOM_PRICE';

/// Default Aave V3 protocol id from backend (`aave_v3`).
const String kHealthFactorAaveV3ProtocolId = 'aave_v3';

enum HealthFactorCalculatorStatus {
  initial,
  loadingProtocols,
  loadingNetworks,
  loadingMarkets,
  ready,
  calculating,
  result,
  error,
  unauthenticated,
}

class HealthFactorSupplyDraft {
  const HealthFactorSupplyDraft({
    required this.id,
    this.assetId,
    this.amount = '',
    this.useAsCollateral = true,
    this.useMarketPrice = true,
    this.customPriceUsd = '',
  });

  final String id;
  final String? assetId;
  final String amount;
  final bool useAsCollateral;
  final bool useMarketPrice;
  final String customPriceUsd;

  HealthFactorSupplyDraft copyWith({
    String? assetId,
    String? amount,
    bool? useAsCollateral,
    bool? useMarketPrice,
    String? customPriceUsd,
    bool clearAssetId = false,
    bool resetCustomPrice = false,
  }) {
    return HealthFactorSupplyDraft(
      id: id,
      assetId: clearAssetId ? null : (assetId ?? this.assetId),
      amount: amount ?? this.amount,
      useAsCollateral: useAsCollateral ?? this.useAsCollateral,
      useMarketPrice: resetCustomPrice ? true : (useMarketPrice ?? this.useMarketPrice),
      customPriceUsd: resetCustomPrice ? '' : (customPriceUsd ?? this.customPriceUsd),
    );
  }
}

class HealthFactorBorrowDraft {
  const HealthFactorBorrowDraft({
    required this.id,
    this.assetId,
    this.amount = '',
    this.useMarketPrice = true,
    this.customPriceUsd = '',
  });

  final String id;
  final String? assetId;
  final String amount;
  final bool useMarketPrice;
  final String customPriceUsd;

  HealthFactorBorrowDraft copyWith({
    String? assetId,
    String? amount,
    bool? useMarketPrice,
    String? customPriceUsd,
    bool clearAssetId = false,
    bool resetCustomPrice = false,
  }) {
    return HealthFactorBorrowDraft(
      id: id,
      assetId: clearAssetId ? null : (assetId ?? this.assetId),
      amount: amount ?? this.amount,
      useMarketPrice: resetCustomPrice ? true : (useMarketPrice ?? this.useMarketPrice),
      customPriceUsd: resetCustomPrice ? '' : (customPriceUsd ?? this.customPriceUsd),
    );
  }
}

class HealthFactorCalculatorState {
  const HealthFactorCalculatorState({
    this.status = HealthFactorCalculatorStatus.initial,
    this.protocols = const <HealthFactorProtocol>[],
    this.selectedProtocol,
    this.networks = const <HealthFactorNetwork>[],
    this.selectedNetwork,
    this.market,
    this.supplies = const <HealthFactorSupplyDraft>[],
    this.borrows = const <HealthFactorBorrowDraft>[],
    this.result,
    this.errorCode,
    this.errorMessage,
    this.requestGeneration = 0,
  });

  final HealthFactorCalculatorStatus status;
  final List<HealthFactorProtocol> protocols;
  final HealthFactorProtocol? selectedProtocol;
  final List<HealthFactorNetwork> networks;
  final HealthFactorNetwork? selectedNetwork;
  final HealthFactorMarketsResult? market;
  final List<HealthFactorSupplyDraft> supplies;
  final List<HealthFactorBorrowDraft> borrows;
  final HealthFactorCalculateResult? result;
  final String? errorCode;
  final String? errorMessage;
  final int requestGeneration;

  bool get hasMarket => market != null;

  List<HealthFactorMarketReserve> get collateralReserves =>
      _reservesWhere((reserve) => reserve.flags.collateralEnabled);

  List<HealthFactorMarketReserve> get supplyReserves =>
      _reservesWhere((reserve) => reserve.flags.supplyEnabled);

  List<HealthFactorMarketReserve> get borrowReserves =>
      _reservesWhere((reserve) => reserve.flags.borrowEnabled);

  bool get canCalculate {
    if (selectedProtocol == null || selectedNetwork == null || !hasMarket) {
      return false;
    }
    return validSupplyRows.isNotEmpty || validBorrowRows.isNotEmpty;
  }

  List<HealthFactorSupplyDraft> get validSupplyRows =>
      supplies.where(_isValidSupplyRow).toList(growable: false);

  List<HealthFactorBorrowDraft> get validBorrowRows =>
      borrows.where(_isValidBorrowRow).toList(growable: false);

  HealthFactorMarketReserve? reserveForAssetId(String? assetId) {
    final trimmed = assetId?.trim();
    if (trimmed == null || trimmed.isEmpty || market == null) {
      return null;
    }
    for (final reserve in market!.reserves) {
      if (reserve.asset.id == trimmed) {
        return reserve;
      }
    }
    return null;
  }

  String? marketPriceUsdForSupplyDraft(HealthFactorSupplyDraft draft) {
    return reserveForAssetId(draft.assetId)?.price.usd;
  }

  String? marketPriceUsdForBorrowDraft(HealthFactorBorrowDraft draft) {
    return reserveForAssetId(draft.assetId)?.price.usd;
  }

  HealthFactorCalculatorState copyWith({
    HealthFactorCalculatorStatus? status,
    List<HealthFactorProtocol>? protocols,
    HealthFactorProtocol? selectedProtocol,
    List<HealthFactorNetwork>? networks,
    HealthFactorNetwork? selectedNetwork,
    HealthFactorMarketsResult? market,
    List<HealthFactorSupplyDraft>? supplies,
    List<HealthFactorBorrowDraft>? borrows,
    HealthFactorCalculateResult? result,
    String? errorCode,
    String? errorMessage,
    int? requestGeneration,
    bool clearSelectedProtocol = false,
    bool clearSelectedNetwork = false,
    bool clearMarket = false,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return HealthFactorCalculatorState(
      status: status ?? this.status,
      protocols: protocols ?? this.protocols,
      selectedProtocol: clearSelectedProtocol
          ? null
          : (selectedProtocol ?? this.selectedProtocol),
      networks: networks ?? this.networks,
      selectedNetwork:
          clearSelectedNetwork ? null : (selectedNetwork ?? this.selectedNetwork),
      market: clearMarket ? null : (market ?? this.market),
      supplies: supplies ?? this.supplies,
      borrows: borrows ?? this.borrows,
      result: clearResult ? null : (result ?? this.result),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      requestGeneration: requestGeneration ?? this.requestGeneration,
    );
  }

  List<HealthFactorMarketReserve> _reservesWhere(
    bool Function(HealthFactorMarketReserve reserve) predicate,
  ) {
    final reserves = market?.reserves;
    if (reserves == null) {
      return const <HealthFactorMarketReserve>[];
    }
    return reserves.where(predicate).toList(growable: false);
  }

  static bool _isValidSupplyRow(HealthFactorSupplyDraft row) {
    final assetId = row.assetId?.trim();
    final amount = row.amount.trim();
    return assetId != null && assetId.isNotEmpty && amount.isNotEmpty;
  }

  static bool _isValidBorrowRow(HealthFactorBorrowDraft row) {
    final assetId = row.assetId?.trim();
    final amount = row.amount.trim();
    return assetId != null && assetId.isNotEmpty && amount.isNotEmpty;
  }
}

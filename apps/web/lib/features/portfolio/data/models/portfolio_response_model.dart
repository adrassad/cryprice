import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_allocation.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_price_status.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

class PortfolioResponseModel {
  const PortfolioResponseModel({required this.portfolio});

  final Portfolio portfolio;

  factory PortfolioResponseModel.fromJson(Map<String, Object?> json) {
    if (kDebugMode) {
      _resetTokenIconParserDebugLogs();
    }
    return PortfolioResponseModel(
      portfolio: Portfolio(
        summary: PortfolioSummaryModel.fromJson(_mapValue(json['summary'])).toEntity(),
        networks: _listValue(json['networks'])
            .map(PortfolioNetworkModel.fromJson)
            .map((model) => model.toEntity())
            .toList(growable: false),
        walletHoldings: _listValue(json['walletHoldings'])
            .map(PortfolioHoldingModel.fromJson)
            .map((model) => model.toEntity())
            .toList(growable: false),
        protocolPositions:
            PortfolioProtocolPositionsModel.fromJson(_mapValue(json['protocolPositions']))
                .toEntity(),
        defiRisk: PortfolioDefiRiskModel.fromJson(_mapValue(json['defiRisk'])).toEntity(),
        totals: PortfolioTotalsModel.fromJson(_mapValue(json['totals'])).toEntity(),
        wallets: _listValue(json['wallets'])
            .map(PortfolioWalletSummaryModel.fromJson)
            .map((model) => model.toEntity())
            .toList(growable: false),
        protocolSummaries: _listValue(json['protocolSummaries'])
            .map(PortfolioProtocolSummaryModel.fromJson)
            .map((model) => model.toEntity())
            .toList(growable: false),
        allocation: PortfolioAllocationModel.fromJson(json['allocation']).toEntity(),
      ),
    );
  }
}

class PortfolioWalletSummaryModel {
  const PortfolioWalletSummaryModel({
    required this.walletId,
    required this.walletAddress,
    required this.walletLabel,
    required this.walletValueUsd,
    required this.suppliedValueUsd,
    required this.borrowedValueUsd,
    required this.grossValueUsd,
    required this.netValueUsd,
    required this.healthFactor,
    required this.healthFactorStatus,
    required this.healthFactorStatusLabel,
  });

  final String walletId;
  final String walletAddress;
  final String? walletLabel;
  final String? walletValueUsd;
  final String? suppliedValueUsd;
  final String? borrowedValueUsd;
  final String? grossValueUsd;
  final String? netValueUsd;
  final String? healthFactor;
  final PortfolioHealthFactorStatus? healthFactorStatus;
  final String? healthFactorStatusLabel;

  factory PortfolioWalletSummaryModel.fromJson(Map<String, Object?> json) {
    return PortfolioWalletSummaryModel(
      walletId: _stringValue(json['walletId']),
      walletAddress: _resolvedWalletAddress(json),
      walletLabel: _resolvedWalletLabel(json),
      walletValueUsd: _nullableStringValue(json['walletValueUsd']),
      suppliedValueUsd: _nullableStringValue(json['suppliedValueUsd']),
      borrowedValueUsd: _nullableStringValue(json['borrowedValueUsd']),
      grossValueUsd: _nullableStringValue(json['grossValueUsd']),
      netValueUsd: _nullableStringValue(json['netValueUsd']),
      healthFactor: _nullableStringValue(json['healthFactor']),
      healthFactorStatus: _nullableHealthFactorStatus(json['healthFactorStatus']),
      healthFactorStatusLabel: _nullableStringValue(json['healthFactorStatusLabel']),
    );
  }

  PortfolioWalletSummary toEntity() {
    return PortfolioWalletSummary(
      walletId: walletId,
      walletAddress: walletAddress,
      walletLabel: walletLabel,
      walletValueUsd: walletValueUsd,
      suppliedValueUsd: suppliedValueUsd,
      borrowedValueUsd: borrowedValueUsd,
      grossValueUsd: grossValueUsd,
      netValueUsd: netValueUsd,
      healthFactor: healthFactor,
      healthFactorStatus: healthFactorStatus,
      healthFactorStatusLabel: healthFactorStatusLabel,
    );
  }
}

class PortfolioProtocolSummaryModel {
  const PortfolioProtocolSummaryModel({
    required this.protocol,
    required this.protocolName,
    required this.category,
    required this.walletValueUsd,
    required this.suppliedValueUsd,
    required this.borrowedValueUsd,
    required this.grossValueUsd,
    required this.netValueUsd,
    required this.totalValueUsd,
    required this.healthFactor,
    required this.healthFactorStatus,
    required this.healthFactorStatusLabel,
    required this.networks,
  });

  final String protocol;
  final String protocolName;
  final String category;
  final String? walletValueUsd;
  final String? suppliedValueUsd;
  final String? borrowedValueUsd;
  final String? grossValueUsd;
  final String? netValueUsd;
  final String? totalValueUsd;
  final String? healthFactor;
  final PortfolioHealthFactorStatus? healthFactorStatus;
  final String? healthFactorStatusLabel;
  final List<PortfolioProtocolNetworkSummaryModel> networks;

  factory PortfolioProtocolSummaryModel.fromJson(Map<String, Object?> json) {
    return PortfolioProtocolSummaryModel(
      protocol: _stringValue(json['protocol']),
      protocolName: _stringValue(json['protocolName']),
      category: _stringValue(json['category']),
      walletValueUsd: _nullableStringValue(json['walletValueUsd']),
      suppliedValueUsd: _nullableStringValue(json['suppliedValueUsd']),
      borrowedValueUsd: _nullableStringValue(json['borrowedValueUsd']),
      grossValueUsd: _nullableStringValue(json['grossValueUsd']),
      netValueUsd: _nullableStringValue(json['netValueUsd']),
      totalValueUsd: _nullableStringValue(json['totalValueUsd']),
      healthFactor: _nullableStringValue(json['healthFactor']),
      healthFactorStatus: _nullableHealthFactorStatus(json['healthFactorStatus']),
      healthFactorStatusLabel: _nullableStringValue(json['healthFactorStatusLabel']),
      networks: _listValue(json['networks'])
          .map(PortfolioProtocolNetworkSummaryModel.fromJson)
          .toList(growable: false),
    );
  }

  PortfolioProtocolSummary toEntity() {
    return PortfolioProtocolSummary(
      protocol: protocol,
      protocolName: protocolName,
      category: category,
      walletValueUsd: walletValueUsd,
      suppliedValueUsd: suppliedValueUsd,
      borrowedValueUsd: borrowedValueUsd,
      grossValueUsd: grossValueUsd,
      netValueUsd: netValueUsd,
      totalValueUsd: totalValueUsd,
      healthFactor: healthFactor,
      healthFactorStatus: healthFactorStatus,
      healthFactorStatusLabel: healthFactorStatusLabel,
      networks: networks.map((model) => model.toEntity()).toList(growable: false),
    );
  }
}

class PortfolioProtocolNetworkSummaryModel {
  const PortfolioProtocolNetworkSummaryModel({
    required this.networkId,
    required this.network,
    required this.networkName,
    required this.netValueUsd,
    required this.healthFactor,
    required this.healthFactorStatus,
    required this.healthFactorStatusLabel,
  });

  final int networkId;
  final String network;
  final String networkName;
  final String? netValueUsd;
  final String? healthFactor;
  final PortfolioHealthFactorStatus? healthFactorStatus;
  final String? healthFactorStatusLabel;

  factory PortfolioProtocolNetworkSummaryModel.fromJson(Map<String, Object?> json) {
    return PortfolioProtocolNetworkSummaryModel(
      networkId: _intValue(json['networkId']),
      network: _stringValue(json['network']),
      networkName: _stringValue(json['networkName']),
      netValueUsd: _nullableStringValue(json['netValueUsd']),
      healthFactor: _nullableStringValue(json['healthFactor']),
      healthFactorStatus: _nullableHealthFactorStatus(json['healthFactorStatus']),
      healthFactorStatusLabel: _nullableStringValue(json['healthFactorStatusLabel']),
    );
  }

  PortfolioProtocolNetworkSummary toEntity() {
    return PortfolioProtocolNetworkSummary(
      networkId: networkId,
      network: network,
      networkName: networkName,
      netValueUsd: netValueUsd,
      healthFactor: healthFactor,
      healthFactorStatus: healthFactorStatus,
      healthFactorStatusLabel: healthFactorStatusLabel,
    );
  }
}

class PortfolioSummaryModel {
  const PortfolioSummaryModel({
    required this.totalValueUsd,
    required this.walletsCount,
    required this.assetsCount,
    required this.networksCount,
    required this.updatedAt,
    required this.walletValueUsd,
    required this.suppliedValueUsd,
    required this.borrowedValueUsd,
    required this.grossValueUsd,
    required this.netValueUsd,
    required this.healthFactor,
    required this.healthFactorStatus,
  });

  final String totalValueUsd;
  final int walletsCount;
  final int assetsCount;
  final int networksCount;
  final String updatedAt;
  final String? walletValueUsd;
  final String? suppliedValueUsd;
  final String? borrowedValueUsd;
  final String? grossValueUsd;
  final String? netValueUsd;
  final String? healthFactor;
  final PortfolioHealthFactorStatus? healthFactorStatus;

  factory PortfolioSummaryModel.fromJson(Map<String, Object?> json) {
    return PortfolioSummaryModel(
      totalValueUsd: _stringValue(json['totalValueUsd']),
      walletValueUsd: _nullableStringValue(json['walletValueUsd']),
      suppliedValueUsd: _nullableStringValue(json['suppliedValueUsd']),
      borrowedValueUsd: _nullableStringValue(json['borrowedValueUsd']),
      grossValueUsd: _nullableStringValue(json['grossValueUsd']),
      netValueUsd: _nullableStringValue(json['netValueUsd']),
      healthFactor: _nullableStringValue(json['healthFactor']),
      healthFactorStatus: _nullableHealthFactorStatus(json['healthFactorStatus']),
      walletsCount: _intValue(json['walletsCount']),
      assetsCount: _intValue(json['assetsCount']),
      networksCount: _intValue(json['networksCount']),
      updatedAt: _stringValue(json['updatedAt']),
    );
  }

  PortfolioSummary toEntity() {
    return PortfolioSummary(
      totalValueUsd: totalValueUsd,
      walletsCount: walletsCount,
      assetsCount: assetsCount,
      networksCount: networksCount,
      updatedAt: updatedAt,
      walletValueUsd: walletValueUsd,
      suppliedValueUsd: suppliedValueUsd,
      borrowedValueUsd: borrowedValueUsd,
      grossValueUsd: grossValueUsd,
      netValueUsd: netValueUsd,
      healthFactor: healthFactor,
      healthFactorStatus: healthFactorStatus,
    );
  }
}

class PortfolioTotalsModel {
  const PortfolioTotalsModel({
    required this.walletValueUsd,
    required this.suppliedValueUsd,
    required this.borrowedValueUsd,
    required this.grossValueUsd,
    required this.netValueUsd,
  });

  final String? walletValueUsd;
  final String? suppliedValueUsd;
  final String? borrowedValueUsd;
  final String? grossValueUsd;
  final String? netValueUsd;

  factory PortfolioTotalsModel.fromJson(Map<String, Object?> json) {
    return PortfolioTotalsModel(
      walletValueUsd: _nullableStringValue(json['walletValueUsd']),
      suppliedValueUsd: _nullableStringValue(json['suppliedValueUsd']),
      borrowedValueUsd: _nullableStringValue(json['borrowedValueUsd']),
      grossValueUsd: _nullableStringValue(json['grossValueUsd']),
      netValueUsd: _nullableStringValue(json['netValueUsd']),
    );
  }

  PortfolioTotals toEntity() {
    return PortfolioTotals(
      walletValueUsd: walletValueUsd,
      suppliedValueUsd: suppliedValueUsd,
      borrowedValueUsd: borrowedValueUsd,
      grossValueUsd: grossValueUsd,
      netValueUsd: netValueUsd,
    );
  }
}

class PortfolioHoldingModel {
  const PortfolioHoldingModel({
    required this.kind,
    required this.networkId,
    required this.network,
    required this.networkName,
    required this.chainId,
    required this.assetId,
    required this.assetSymbol,
    required this.assetAddress,
    required this.symbol,
    required this.address,
    required this.amount,
    required this.balanceRaw,
    required this.decimals,
    required this.priceUsd,
    required this.valueUsd,
    required this.priceStatus,
    required this.wallets,
    this.logoUrl,
  });

  final String kind;
  final int networkId;
  final String network;
  final String networkName;
  final int chainId;
  final String assetId;
  final String assetSymbol;
  final String? assetAddress;
  final String symbol;
  final String? address;
  final String? amount;
  final String? balanceRaw;
  final int decimals;
  final String? priceUsd;
  final String? valueUsd;
  final PortfolioPriceStatus priceStatus;
  final List<PortfolioWalletBreakdownModel> wallets;
  final String? logoUrl;

  factory PortfolioHoldingModel.fromJson(Map<String, Object?> json) {
    return PortfolioHoldingModel(
      kind: _stringValue(json['kind']),
      networkId: _intValue(json['networkId']),
      network: _stringValue(json['network']),
      networkName: _stringValue(json['networkName']),
      chainId: _intValue(json['chainId']),
      assetId: _stringValue(json['assetId']),
      assetSymbol: _stringValue(json['assetSymbol']),
      assetAddress: _nullableStringValue(json['assetAddress']),
      symbol: _stringValue(json['symbol']),
      address: _nullableStringValue(json['address']),
      amount: _nullableStringValue(json['amount']),
      balanceRaw: _nullableStringValue(json['balanceRaw']),
      decimals: _intValue(json['decimals']),
      priceUsd: _nullableStringValue(json['priceUsd']),
      valueUsd: _nullableStringValue(json['valueUsd']),
      priceStatus: PortfolioPriceStatus.fromJson(json['priceStatus']),
      wallets: _listValue(json['wallets'])
          .map(PortfolioWalletBreakdownModel.fromJson)
          .toList(growable: false),
      logoUrl: _nullableLogoUrlFromJson(json),
    );
  }

  PortfolioHolding toEntity() {
    return PortfolioHolding(
      kind: kind,
      networkId: networkId,
      network: network,
      networkName: networkName,
      chainId: chainId,
      assetId: assetId,
      assetSymbol: assetSymbol,
      assetAddress: assetAddress,
      symbol: symbol,
      address: address,
      amount: amount,
      balanceRaw: balanceRaw,
      decimals: decimals,
      priceUsd: priceUsd,
      valueUsd: valueUsd,
      priceStatus: priceStatus,
      logoUrl: logoUrl,
      wallets: wallets.map((model) => model.toEntity()).toList(growable: false),
    );
  }
}

class PortfolioProtocolPositionsModel {
  const PortfolioProtocolPositionsModel({
    required this.supplied,
    required this.borrowed,
  });

  final List<PortfolioProtocolPositionModel> supplied;
  final List<PortfolioProtocolPositionModel> borrowed;

  factory PortfolioProtocolPositionsModel.fromJson(Map<String, Object?> json) {
    return PortfolioProtocolPositionsModel(
      supplied: _listValue(json['supplied'])
          .map(PortfolioProtocolPositionModel.fromJson)
          .toList(growable: false),
      borrowed: _listValue(json['borrowed'])
          .map(PortfolioProtocolPositionModel.fromJson)
          .toList(growable: false),
    );
  }

  PortfolioProtocolPositions toEntity() {
    return PortfolioProtocolPositions(
      supplied: supplied.map((model) => model.toEntity()).toList(growable: false),
      borrowed: borrowed.map((model) => model.toEntity()).toList(growable: false),
    );
  }
}

class PortfolioProtocolPositionModel {
  const PortfolioProtocolPositionModel({
    required this.kind,
    required this.protocol,
    required this.protocolName,
    required this.networkId,
    required this.network,
    required this.networkName,
    required this.chainId,
    required this.positionSide,
    required this.tokenRole,
    required this.debtType,
    required this.underlyingSymbol,
    required this.underlyingAddress,
    required this.tokenSymbol,
    required this.tokenAddress,
    required this.amount,
    required this.balanceRaw,
    required this.decimals,
    required this.priceUsd,
    required this.valueUsd,
    required this.priceStatus,
    required this.wallets,
    this.logoUrl,
  });

  final String kind;
  final String protocol;
  final String protocolName;
  final int networkId;
  final String network;
  final String networkName;
  final int chainId;
  final PortfolioPositionSide positionSide;
  final String tokenRole;
  final PortfolioDebtType? debtType;
  final String underlyingSymbol;
  final String? underlyingAddress;
  final String tokenSymbol;
  final String? tokenAddress;
  final String? amount;
  final String? balanceRaw;
  final int decimals;
  final String? priceUsd;
  final String? valueUsd;
  final PortfolioPriceStatus priceStatus;
  final List<PortfolioWalletBreakdownModel> wallets;
  final String? logoUrl;

  factory PortfolioProtocolPositionModel.fromJson(Map<String, Object?> json) {
    return PortfolioProtocolPositionModel(
      kind: _stringValue(json['kind']),
      protocol: _stringValue(json['protocol']),
      protocolName: _stringValue(json['protocolName']),
      networkId: _intValue(json['networkId']),
      network: _stringValue(json['network']),
      networkName: _stringValue(json['networkName']),
      chainId: _intValue(json['chainId']),
      positionSide: PortfolioPositionSide.fromJson(json['positionSide']),
      tokenRole: _stringValue(json['tokenRole']),
      debtType: PortfolioDebtType.fromJson(json['debtType']),
      underlyingSymbol: _stringValue(json['underlyingSymbol']),
      underlyingAddress: _nullableStringValue(json['underlyingAddress']),
      tokenSymbol: _stringValue(json['tokenSymbol']),
      tokenAddress: _nullableStringValue(json['tokenAddress']),
      amount: _nullableStringValue(json['amount']),
      balanceRaw: _nullableStringValue(json['balanceRaw']),
      decimals: _intValue(json['decimals']),
      priceUsd: _nullableStringValue(json['priceUsd']),
      valueUsd: _nullableStringValue(json['valueUsd']),
      priceStatus: PortfolioPriceStatus.fromJson(json['priceStatus']),
      wallets: _listValue(json['wallets'])
          .map(PortfolioWalletBreakdownModel.fromJson)
          .toList(growable: false),
      logoUrl: _nullableLogoUrlFromJson(json),
    );
  }

  PortfolioProtocolPosition toEntity() {
    return PortfolioProtocolPosition(
      kind: kind,
      protocol: protocol,
      protocolName: protocolName,
      networkId: networkId,
      network: network,
      networkName: networkName,
      chainId: chainId,
      positionSide: positionSide,
      tokenRole: tokenRole,
      debtType: debtType,
      underlyingSymbol: underlyingSymbol,
      underlyingAddress: underlyingAddress,
      tokenSymbol: tokenSymbol,
      tokenAddress: tokenAddress,
      amount: amount,
      balanceRaw: balanceRaw,
      decimals: decimals,
      priceUsd: priceUsd,
      valueUsd: valueUsd,
      priceStatus: priceStatus,
      logoUrl: logoUrl,
      wallets: wallets.map((model) => model.toEntity()).toList(growable: false),
    );
  }
}

class PortfolioDefiRiskModel {
  const PortfolioDefiRiskModel({
    required this.healthFactor,
    required this.positionsHealth,
  });

  final PortfolioHealthFactorModel? healthFactor;
  final List<PortfolioPositionHealthModel> positionsHealth;

  factory PortfolioDefiRiskModel.fromJson(Map<String, Object?> json) {
    final healthFactorJson = _nullableMapValue(json['healthFactor']);
    return PortfolioDefiRiskModel(
      healthFactor: healthFactorJson == null
          ? null
          : PortfolioHealthFactorModel.fromJson(healthFactorJson),
      positionsHealth: _listValue(json['positionsHealth'])
          .map(PortfolioPositionHealthModel.fromJson)
          .toList(growable: false),
    );
  }

  PortfolioDefiRisk toEntity() {
    return PortfolioDefiRisk(
      healthFactor: healthFactor?.toEntity(),
      positionsHealth:
          positionsHealth.map((model) => model.toEntity()).toList(growable: false),
    );
  }
}

class PortfolioHealthFactorModel {
  const PortfolioHealthFactorModel({
    required this.value,
    required this.status,
    required this.statusLabel,
    required this.protocol,
    required this.protocolName,
    required this.updatedAt,
    required this.stale,
  });

  final String? value;
  final PortfolioHealthFactorStatus status;
  final String? statusLabel;
  final String? protocol;
  final String? protocolName;
  final String? updatedAt;
  final bool stale;

  factory PortfolioHealthFactorModel.fromJson(Map<String, Object?> json) {
    return PortfolioHealthFactorModel(
      value: _nullableStringValue(json['value']),
      status: PortfolioHealthFactorStatus.fromJson(json['status']),
      statusLabel: _nullableStringValue(json['statusLabel']),
      protocol: _nullableStringValue(json['protocol']),
      protocolName: _nullableStringValue(json['protocolName']),
      updatedAt: _nullableStringValue(json['updatedAt']),
      stale: _boolValue(json['stale']),
    );
  }

  PortfolioHealthFactor toEntity() {
    return PortfolioHealthFactor(
      value: value,
      status: status,
      statusLabel: statusLabel,
      protocol: protocol,
      protocolName: protocolName,
      updatedAt: updatedAt,
      stale: stale,
    );
  }
}

class PortfolioPositionHealthModel {
  const PortfolioPositionHealthModel({
    required this.protocol,
    required this.protocolName,
    required this.networkId,
    required this.network,
    required this.networkName,
    required this.walletId,
    required this.walletAddress,
    required this.walletLabel,
    required this.healthFactor,
    required this.status,
    required this.statusLabel,
    required this.threshold,
    required this.updatedAt,
    required this.stale,
  });

  final String protocol;
  final String protocolName;
  final int networkId;
  final String network;
  final String networkName;
  final String walletId;
  final String walletAddress;
  final String? walletLabel;
  final String? healthFactor;
  final PortfolioHealthFactorStatus status;
  final String? statusLabel;
  final String? threshold;
  final String? updatedAt;
  final bool stale;

  factory PortfolioPositionHealthModel.fromJson(Map<String, Object?> json) {
    return PortfolioPositionHealthModel(
      protocol: _stringValue(json['protocol']),
      protocolName: _stringValue(json['protocolName']),
      networkId: _intValue(json['networkId']),
      network: _stringValue(json['network']),
      networkName: _stringValue(json['networkName']),
      walletId: _stringValue(json['walletId']),
      walletAddress: _resolvedWalletAddress(json),
      walletLabel: _resolvedWalletLabel(json),
      healthFactor: _nullableStringValue(json['healthFactor']),
      status: PortfolioHealthFactorStatus.fromJson(json['status']),
      statusLabel: _nullableStringValue(json['statusLabel']),
      threshold: _nullableStringValue(json['threshold']),
      updatedAt: _nullableStringValue(json['updatedAt']),
      stale: _boolValue(json['stale']),
    );
  }

  PortfolioPositionHealth toEntity() {
    return PortfolioPositionHealth(
      protocol: protocol,
      protocolName: protocolName,
      networkId: networkId,
      network: network,
      networkName: networkName,
      walletId: walletId,
      walletAddress: walletAddress,
      walletLabel: walletLabel,
      healthFactor: healthFactor,
      status: status,
      statusLabel: statusLabel,
      threshold: threshold,
      updatedAt: updatedAt,
      stale: stale,
    );
  }
}

class PortfolioNetworkModel {
  const PortfolioNetworkModel({
    required this.networkId,
    required this.chainId,
    required this.name,
    required this.nativeSymbol,
    required this.totalValueUsd,
    required this.assets,
  });

  final int networkId;
  final int chainId;
  final String name;
  final String nativeSymbol;
  final String totalValueUsd;
  final List<PortfolioAssetModel> assets;

  factory PortfolioNetworkModel.fromJson(Map<String, Object?> json) {
    return PortfolioNetworkModel(
      networkId: _intValue(json['networkId']),
      chainId: _intValue(json['chainId']),
      name: _stringValue(json['name']),
      nativeSymbol: _stringValue(json['nativeSymbol']),
      totalValueUsd: _stringValue(json['totalValueUsd']),
      assets: _listValue(json['assets'])
          .map(PortfolioAssetModel.fromJson)
          .toList(growable: false),
    );
  }

  PortfolioNetwork toEntity() {
    return PortfolioNetwork(
      networkId: networkId,
      chainId: chainId,
      name: name,
      nativeSymbol: nativeSymbol,
      totalValueUsd: totalValueUsd,
      assets: assets.map((model) => model.toEntity()).toList(growable: false),
    );
  }
}

class PortfolioAssetModel {
  const PortfolioAssetModel({
    required this.assetId,
    required this.symbol,
    required this.address,
    required this.decimals,
    required this.balanceRaw,
    required this.balance,
    required this.priceUsd,
    required this.valueUsd,
    required this.priceStatus,
    required this.priceCalculatedAt,
    required this.balanceSyncedAt,
    required this.wallets,
    this.logoUrl,
  });

  final String assetId;
  final String symbol;
  final String? address;
  final int decimals;
  final String balanceRaw;
  final String balance;
  final String? priceUsd;
  final String? valueUsd;
  final PortfolioPriceStatus priceStatus;
  final String? priceCalculatedAt;
  final String? balanceSyncedAt;
  final List<PortfolioWalletBreakdownModel> wallets;
  final String? logoUrl;

  factory PortfolioAssetModel.fromJson(Map<String, Object?> json) {
    return PortfolioAssetModel(
      assetId: _stringValue(json['assetId']),
      symbol: _stringValue(json['symbol']),
      address: _nullableStringValue(json['address']),
      decimals: _intValue(json['decimals']),
      balanceRaw: _stringValue(json['balanceRaw']),
      balance: _stringValue(json['balance']),
      priceUsd: _nullableStringValue(json['priceUsd']),
      valueUsd: _nullableStringValue(json['valueUsd']),
      priceStatus: PortfolioPriceStatus.fromJson(json['priceStatus']),
      priceCalculatedAt: _nullableStringValue(json['priceCalculatedAt']),
      balanceSyncedAt: _nullableStringValue(json['balanceSyncedAt']),
      wallets: _listValue(json['wallets'])
          .map(PortfolioWalletBreakdownModel.fromJson)
          .toList(growable: false),
      logoUrl: _nullableLogoUrlFromJson(json),
    );
  }

  PortfolioAsset toEntity() {
    return PortfolioAsset(
      assetId: assetId,
      symbol: symbol,
      address: address,
      decimals: decimals,
      balanceRaw: balanceRaw,
      balance: balance,
      priceUsd: priceUsd,
      valueUsd: valueUsd,
      priceStatus: priceStatus,
      priceCalculatedAt: priceCalculatedAt,
      balanceSyncedAt: balanceSyncedAt,
      wallets: wallets.map((model) => model.toEntity()).toList(growable: false),
      logoUrl: logoUrl,
    );
  }
}

class PortfolioWalletBreakdownModel {
  const PortfolioWalletBreakdownModel({
    required this.walletId,
    required this.address,
    required this.label,
    required this.walletAddress,
    required this.walletLabel,
    required this.amount,
    required this.balanceRaw,
    required this.balance,
    required this.valueUsd,
    required this.syncedAt,
    required this.blockNumber,
  });

  final String walletId;
  final String address;
  final String? label;
  final String walletAddress;
  final String? walletLabel;
  final String? amount;
  final String balanceRaw;
  final String balance;
  final String? valueUsd;
  final String? syncedAt;
  final int? blockNumber;

  factory PortfolioWalletBreakdownModel.fromJson(Map<String, Object?> json) {
    final resolvedAddress = _resolvedWalletAddress(json);
    final resolvedLabel = _resolvedWalletLabel(json);
    final amount = _nullableStringValue(json['amount']);
    final balance = _nullableStringValue(json['balance']);
    final resolvedBalance =
        balance != null && balance.isNotEmpty ? balance : (amount ?? '');

    return PortfolioWalletBreakdownModel(
      walletId: _stringValue(json['walletId']),
      address: resolvedAddress,
      label: resolvedLabel,
      walletAddress: resolvedAddress,
      walletLabel: resolvedLabel,
      amount: amount,
      balanceRaw: _nullableStringValue(json['balanceRaw']) ?? '',
      balance: resolvedBalance,
      valueUsd: _nullableStringValue(json['valueUsd']),
      syncedAt: _nullableStringValue(json['syncedAt']),
      blockNumber: _nullableIntValue(json['blockNumber']),
    );
  }

  PortfolioWalletBreakdown toEntity() {
    return PortfolioWalletBreakdown(
      walletId: walletId,
      address: address,
      label: label,
      walletAddress: walletAddress,
      walletLabel: walletLabel,
      amount: amount,
      balanceRaw: balanceRaw,
      balance: balance,
      valueUsd: valueUsd,
      syncedAt: syncedAt,
      blockNumber: blockNumber,
    );
  }
}

class PortfolioAllocationModel {
  const PortfolioAllocationModel({
    required this.assets,
    required this.debts,
    required this.protocols,
    required this.networks,
    required this.wallets,
  });

  final List<PortfolioAllocationItemModel> assets;
  final List<PortfolioAllocationItemModel> debts;
  final List<PortfolioAllocationItemModel> protocols;
  final List<PortfolioAllocationItemModel> networks;
  final List<PortfolioWalletAllocationModel> wallets;

  factory PortfolioAllocationModel.fromJson(Object? value) {
    final json = _nullableMapValue(value);
    if (json == null) {
      return const PortfolioAllocationModel(
        assets: <PortfolioAllocationItemModel>[],
        debts: <PortfolioAllocationItemModel>[],
        protocols: <PortfolioAllocationItemModel>[],
        networks: <PortfolioAllocationItemModel>[],
        wallets: <PortfolioWalletAllocationModel>[],
      );
    }

    return PortfolioAllocationModel(
      assets: _parseAllocationItems(json['assets']),
      debts: _parseAllocationItems(json['debts']),
      protocols: _parseAllocationItems(json['protocols']),
      networks: _parseAllocationItems(json['networks']),
      wallets: _listValue(json['wallets'])
          .map(PortfolioWalletAllocationModel.fromJson)
          .toList(growable: false),
    );
  }

  PortfolioAllocation? toEntity() {
    if (assets.isEmpty &&
        debts.isEmpty &&
        protocols.isEmpty &&
        networks.isEmpty &&
        wallets.isEmpty) {
      return null;
    }

    return PortfolioAllocation(
      assets: assets.map((item) => item.toEntity()).toList(growable: false),
      debts: debts.map((item) => item.toEntity()).toList(growable: false),
      protocols: protocols.map((item) => item.toEntity()).toList(growable: false),
      networks: networks.map((item) => item.toEntity()).toList(growable: false),
      wallets: wallets.map((item) => item.toEntity()).toList(growable: false),
    );
  }

  static List<PortfolioAllocationItemModel> _parseAllocationItems(Object? value) {
    return _listValue(value)
        .map(PortfolioAllocationItemModel.fromJson)
        .toList(growable: false);
  }
}

class PortfolioWalletAllocationModel {
  const PortfolioWalletAllocationModel({
    required this.walletId,
    required this.walletAddress,
    required this.walletLabel,
    required this.assets,
    required this.debts,
    required this.protocols,
    required this.networks,
  });

  final String walletId;
  final String walletAddress;
  final String? walletLabel;
  final List<PortfolioAllocationItemModel> assets;
  final List<PortfolioAllocationItemModel> debts;
  final List<PortfolioAllocationItemModel> protocols;
  final List<PortfolioAllocationItemModel> networks;

  factory PortfolioWalletAllocationModel.fromJson(Map<String, Object?> json) {
    return PortfolioWalletAllocationModel(
      walletId: _stringValue(json['walletId']),
      walletAddress: _resolvedWalletAddress(json),
      walletLabel: _resolvedWalletLabel(json),
      assets: PortfolioAllocationModel._parseAllocationItems(json['assets']),
      debts: PortfolioAllocationModel._parseAllocationItems(json['debts']),
      protocols: PortfolioAllocationModel._parseAllocationItems(json['protocols']),
      networks: PortfolioAllocationModel._parseAllocationItems(json['networks']),
    );
  }

  PortfolioWalletAllocation toEntity() {
    return PortfolioWalletAllocation(
      walletId: walletId,
      walletAddress: walletAddress,
      walletLabel: walletLabel,
      assets: assets.map((item) => item.toEntity()).toList(growable: false),
      debts: debts.map((item) => item.toEntity()).toList(growable: false),
      protocols: protocols.map((item) => item.toEntity()).toList(growable: false),
      networks: networks.map((item) => item.toEntity()).toList(growable: false),
    );
  }
}

class PortfolioAllocationItemModel {
  const PortfolioAllocationItemModel({
    required this.key,
    required this.label,
    required this.valueUsd,
    required this.percentage,
    required this.source,
    required this.protocol,
    required this.protocolName,
    required this.category,
    required this.network,
    required this.networkName,
    required this.networkId,
    required this.assetSymbol,
    required this.priceUsd,
    required this.priceStatus,
    required this.debtType,
    required this.walletValueUsd,
    required this.suppliedValueUsd,
    required this.borrowedValueUsd,
    required this.grossValueUsd,
    required this.netValueUsd,
    required this.childrenCount,
    this.logoUrl,
  });

  final String key;
  final String label;
  final String valueUsd;
  final String percentage;
  final String? source;
  final String? protocol;
  final String? protocolName;
  final String? category;
  final String? network;
  final String? networkName;
  final int? networkId;
  final String? assetSymbol;
  final String? priceUsd;
  final PortfolioPriceStatus? priceStatus;
  final String? debtType;
  final String? walletValueUsd;
  final String? suppliedValueUsd;
  final String? borrowedValueUsd;
  final String? grossValueUsd;
  final String? netValueUsd;
  final int? childrenCount;
  final String? logoUrl;

  factory PortfolioAllocationItemModel.fromJson(Map<String, Object?> json) {
    return PortfolioAllocationItemModel(
      key: _stringValue(json['key']),
      label: _stringValue(json['label']),
      valueUsd: _stringValue(json['valueUsd']),
      percentage: _stringValue(json['percentage']),
      source: _nullableStringValue(json['source']),
      protocol: _nullableStringValue(json['protocol']),
      protocolName: _nullableStringValue(json['protocolName']),
      category: _nullableStringValue(json['category']),
      network: _nullableStringValue(json['network']),
      networkName: _nullableStringValue(json['networkName']),
      networkId: _nullableIntValue(json['networkId']),
      assetSymbol: _nullableStringValue(json['assetSymbol']),
      priceUsd: _nullableStringValue(json['priceUsd']),
      priceStatus: _nullablePriceStatus(json['priceStatus']),
      debtType: _nullableStringValue(json['debtType']),
      walletValueUsd: _nullableStringValue(json['walletValueUsd']),
      suppliedValueUsd: _nullableStringValue(json['suppliedValueUsd']),
      borrowedValueUsd: _nullableStringValue(json['borrowedValueUsd']),
      grossValueUsd: _nullableStringValue(json['grossValueUsd']),
      netValueUsd: _nullableStringValue(json['netValueUsd']),
      childrenCount: _nullableIntValue(json['childrenCount']),
      logoUrl: _nullableLogoUrlFromJson(json),
    );
  }

  PortfolioAllocationItem toEntity() {
    return PortfolioAllocationItem(
      key: key,
      label: label,
      valueUsd: valueUsd,
      percentage: percentage,
      source: source,
      protocol: protocol,
      protocolName: protocolName,
      category: category,
      network: network,
      networkName: networkName,
      networkId: networkId,
      assetSymbol: assetSymbol,
      priceUsd: priceUsd,
      priceStatus: priceStatus,
      debtType: debtType,
      walletValueUsd: walletValueUsd,
      suppliedValueUsd: suppliedValueUsd,
      borrowedValueUsd: borrowedValueUsd,
      grossValueUsd: grossValueUsd,
      netValueUsd: netValueUsd,
      childrenCount: childrenCount,
      logoUrl: logoUrl,
    );
  }
}

PortfolioPriceStatus? _nullablePriceStatus(Object? value) {
  if (value == null) {
    return null;
  }
  return PortfolioPriceStatus.fromJson(value);
}

String _resolvedWalletAddress(Map<String, Object?> json) {
  final alias = _nullableStringValue(json['walletAddress']);
  if (alias != null && alias.isNotEmpty) {
    return alias;
  }
  return _stringValue(json['address']);
}

String? _resolvedWalletLabel(Map<String, Object?> json) {
  final alias = _nullableStringValue(json['walletLabel']);
  if (alias != null && alias.isNotEmpty) {
    return alias;
  }
  return _nullableStringValue(json['label']);
}

Map<String, Object?> _mapValue(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return value.cast<String, Object?>();
  }
  return const <String, Object?>{};
}

Map<String, Object?>? _nullableMapValue(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return value.cast<String, Object?>();
  }
  return null;
}

List<Map<String, Object?>> _listValue(Object? value) {
  if (value is! List) {
    return const <Map<String, Object?>>[];
  }
  return value
      .whereType<Map>()
      .map((item) => item.cast<String, Object?>())
      .toList(growable: false);
}

String _stringValue(Object? value) => value?.toString() ?? '';

String? _nullableStringValue(Object? value) => value?.toString();

String? _nullableLogoUrlFromJson(Map<String, Object?> json) {
  final raw = json['logo_url'] ?? json['logoUrl'];
  final trimmed = _nullableStringValue(raw)?.trim();
  final parsed = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  final String? source;
  if (json['logo_url'] != null) {
    source = 'logo_url';
  } else if (json['logoUrl'] != null) {
    source = 'logoUrl';
  } else {
    source = null;
  }
  _logTokenIconParserDebug(json, parsed, source);
  return parsed;
}

int _tokenIconParserDebugLogCount = 0;

void _resetTokenIconParserDebugLogs() {
  _tokenIconParserDebugLogCount = 0;
}

void _logTokenIconParserDebug(
  Map<String, Object?> json,
  String? parsedLogoUrl,
  String? source,
) {
  if (!kDebugMode || _tokenIconParserDebugLogCount >= 5) {
    return;
  }
  _tokenIconParserDebugLogCount++;
  final symbol =
      _nullableStringValue(json['symbol']) ??
      _nullableStringValue(json['tokenSymbol']) ??
      _nullableStringValue(json['underlyingSymbol']) ??
      _nullableStringValue(json['assetSymbol']) ??
      _nullableStringValue(json['label']) ??
      '?';
  debugPrint(
    '[TokenIcon][Parser] symbol=$symbol '
    'parsedLogoUrl=${parsedLogoUrl ?? '(null)'} '
    'source=${source ?? 'none'}',
  );
}

PortfolioHealthFactorStatus? _nullableHealthFactorStatus(Object? value) {
  if (value == null) {
    return null;
  }
  return PortfolioHealthFactorStatus.fromJson(value);
}

bool _boolValue(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is String) {
    return value.toLowerCase() == 'true';
  }
  return false;
}

int _intValue(Object? value) => _nullableIntValue(value) ?? 0;

int? _nullableIntValue(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

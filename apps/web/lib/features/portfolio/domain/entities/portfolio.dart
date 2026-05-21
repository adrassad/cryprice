import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_allocation.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_price_status.dart';

class Portfolio {
  const Portfolio({
    required this.summary,
    required this.networks,
    this.walletHoldings = const <PortfolioHolding>[],
    this.protocolPositions = const PortfolioProtocolPositions(),
    this.defiRisk = const PortfolioDefiRisk(),
    this.totals = const PortfolioTotals(),
    this.wallets = const <PortfolioWalletSummary>[],
    this.protocolSummaries = const <PortfolioProtocolSummary>[],
    this.allocation,
  });

  final PortfolioSummary summary;
  final List<PortfolioNetwork> networks;
  final List<PortfolioHolding> walletHoldings;
  final PortfolioProtocolPositions protocolPositions;
  final PortfolioDefiRisk defiRisk;
  final PortfolioTotals totals;
  final List<PortfolioWalletSummary> wallets;
  final List<PortfolioProtocolSummary> protocolSummaries;
  final PortfolioAllocation? allocation;

  bool get hasWalletSummaries => wallets.isNotEmpty;

  bool get hasProtocolSummaries => protocolSummaries.isNotEmpty;

  bool get hasAllocation => allocation != null && !allocation!.isEmpty;

  String? get mainNetValueUsd {
    final summaryNetValue = summary.netValueUsd?.trim();
    if (summaryNetValue != null && summaryNetValue.isNotEmpty) {
      return summary.netValueUsd;
    }

    final totalsNetValue = totals.netValueUsd?.trim();
    if (totalsNetValue != null && totalsNetValue.isNotEmpty) {
      return totals.netValueUsd;
    }

    final legacyTotalValue = summary.totalValueUsd.trim();
    if (legacyTotalValue.isNotEmpty) {
      return summary.totalValueUsd;
    }

    return null;
  }

  bool get hasWalletHoldings => walletHoldings.isNotEmpty;

  bool get hasSuppliedPositions => protocolPositions.supplied.isNotEmpty;

  bool get hasBorrowedPositions => protocolPositions.borrowed.isNotEmpty;

  bool get hasDeFiPositions => hasSuppliedPositions || hasBorrowedPositions;

  bool get hasHealthFactor => defiRisk.healthFactor != null;

  bool get hasPositionsHealth => defiRisk.positionsHealth.isNotEmpty;

  bool get hasRiskData {
    return hasHealthFactor || defiRisk.positionsHealth.isNotEmpty;
  }

  bool get hasLegacyNetworkAssets {
    return networks.any((network) => network.assets.isNotEmpty);
  }

  bool get isEmpty {
    return !hasWalletHoldings &&
        !hasDeFiPositions &&
        !hasLegacyNetworkAssets &&
        !hasPositionsHealth &&
        !hasHealthFactor;
  }
}

class PortfolioSummary {
  const PortfolioSummary({
    required this.totalValueUsd,
    required this.walletsCount,
    required this.assetsCount,
    required this.networksCount,
    required this.updatedAt,
    this.walletValueUsd,
    this.suppliedValueUsd,
    this.borrowedValueUsd,
    this.grossValueUsd,
    this.netValueUsd,
    this.healthFactor,
    this.healthFactorStatus,
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
}

class PortfolioTotals {
  const PortfolioTotals({
    this.walletValueUsd,
    this.suppliedValueUsd,
    this.borrowedValueUsd,
    this.grossValueUsd,
    this.netValueUsd,
  });

  final String? walletValueUsd;
  final String? suppliedValueUsd;
  final String? borrowedValueUsd;
  final String? grossValueUsd;
  final String? netValueUsd;
}

class PortfolioWalletSummary {
  const PortfolioWalletSummary({
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
}

class PortfolioProtocolSummary {
  const PortfolioProtocolSummary({
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
    this.networks = const <PortfolioProtocolNetworkSummary>[],
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
  final List<PortfolioProtocolNetworkSummary> networks;
}

class PortfolioProtocolNetworkSummary {
  const PortfolioProtocolNetworkSummary({
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
}

class PortfolioHolding {
  const PortfolioHolding({
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
    this.logoUrl,
    this.wallets = const <PortfolioWalletBreakdown>[],
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
  final String? logoUrl;
  final List<PortfolioWalletBreakdown> wallets;
}

class PortfolioProtocolPositions {
  const PortfolioProtocolPositions({
    this.supplied = const <PortfolioProtocolPosition>[],
    this.borrowed = const <PortfolioProtocolPosition>[],
  });

  final List<PortfolioProtocolPosition> supplied;
  final List<PortfolioProtocolPosition> borrowed;
}

class PortfolioProtocolPosition {
  const PortfolioProtocolPosition({
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
    this.logoUrl,
    this.wallets = const <PortfolioWalletBreakdown>[],
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
  final String? logoUrl;
  final List<PortfolioWalletBreakdown> wallets;
}

class PortfolioDefiRisk {
  const PortfolioDefiRisk({
    this.healthFactor,
    this.positionsHealth = const <PortfolioPositionHealth>[],
  });

  final PortfolioHealthFactor? healthFactor;
  final List<PortfolioPositionHealth> positionsHealth;
}

class PortfolioHealthFactor {
  const PortfolioHealthFactor({
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
}

class PortfolioPositionHealth {
  const PortfolioPositionHealth({
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
}

enum PortfolioHealthFactorStatus {
  none,
  noDebt,
  safe,
  watch,
  warning,
  atRisk,
  liquidationRisk,
  missing,
  stale,
  unknown;

  factory PortfolioHealthFactorStatus.fromJson(Object? value) {
    return switch (value?.toString()) {
      'none' => PortfolioHealthFactorStatus.none,
      'no_debt' => PortfolioHealthFactorStatus.noDebt,
      'safe' => PortfolioHealthFactorStatus.safe,
      'watch' => PortfolioHealthFactorStatus.watch,
      'warning' => PortfolioHealthFactorStatus.warning,
      'at_risk' => PortfolioHealthFactorStatus.atRisk,
      'liquidation_risk' => PortfolioHealthFactorStatus.liquidationRisk,
      'missing' => PortfolioHealthFactorStatus.missing,
      'stale' => PortfolioHealthFactorStatus.stale,
      _ => PortfolioHealthFactorStatus.unknown,
    };
  }
}

enum PortfolioPositionSide {
  supplied,
  borrowed,
  unknown;

  factory PortfolioPositionSide.fromJson(Object? value) {
    return switch (value?.toString()) {
      'supplied' => PortfolioPositionSide.supplied,
      'borrowed' => PortfolioPositionSide.borrowed,
      _ => PortfolioPositionSide.unknown,
    };
  }
}

enum PortfolioDebtType {
  stable,
  variable,
  unknown;

  static PortfolioDebtType? fromJson(Object? value) {
    return switch (value?.toString()) {
      null || '' => null,
      'stable' => PortfolioDebtType.stable,
      'variable' => PortfolioDebtType.variable,
      _ => PortfolioDebtType.unknown,
    };
  }
}

class PortfolioNetwork {
  const PortfolioNetwork({
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
  final List<PortfolioAsset> assets;
}

class PortfolioAsset {
  const PortfolioAsset({
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
  final List<PortfolioWalletBreakdown> wallets;
  final String? logoUrl;
}

class PortfolioWalletBreakdown {
  const PortfolioWalletBreakdown({
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
}

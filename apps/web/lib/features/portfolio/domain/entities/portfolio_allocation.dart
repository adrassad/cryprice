import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_price_status.dart';

/// Backend-provided allocation slice. Financial fields stay as [String].
class PortfolioAllocationItem {
  const PortfolioAllocationItem({
    required this.key,
    required this.label,
    required this.valueUsd,
    required this.percentage,
    this.source,
    this.protocol,
    this.protocolName,
    this.category,
    this.network,
    this.networkName,
    this.networkId,
    this.assetSymbol,
    this.priceUsd,
    this.priceStatus,
    this.debtType,
    this.walletValueUsd,
    this.suppliedValueUsd,
    this.borrowedValueUsd,
    this.grossValueUsd,
    this.netValueUsd,
    this.childrenCount,
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
}

/// Wallet-scoped allocation from backend.
class PortfolioWalletAllocation {
  const PortfolioWalletAllocation({
    required this.walletId,
    required this.walletAddress,
    required this.walletLabel,
    this.assets = const <PortfolioAllocationItem>[],
    this.debts = const <PortfolioAllocationItem>[],
    this.protocols = const <PortfolioAllocationItem>[],
    this.networks = const <PortfolioAllocationItem>[],
  });

  final String walletId;
  final String walletAddress;
  final String? walletLabel;
  final List<PortfolioAllocationItem> assets;
  final List<PortfolioAllocationItem> debts;
  final List<PortfolioAllocationItem> protocols;
  final List<PortfolioAllocationItem> networks;
}

/// Top-level allocation block from backend.
class PortfolioAllocation {
  const PortfolioAllocation({
    this.assets = const <PortfolioAllocationItem>[],
    this.debts = const <PortfolioAllocationItem>[],
    this.protocols = const <PortfolioAllocationItem>[],
    this.networks = const <PortfolioAllocationItem>[],
    this.wallets = const <PortfolioWalletAllocation>[],
  });

  final List<PortfolioAllocationItem> assets;
  final List<PortfolioAllocationItem> debts;
  final List<PortfolioAllocationItem> protocols;
  final List<PortfolioAllocationItem> networks;
  final List<PortfolioWalletAllocation> wallets;

  bool get isEmpty {
    return assets.isEmpty &&
        debts.isEmpty &&
        protocols.isEmpty &&
        networks.isEmpty &&
        wallets.isEmpty;
  }
}

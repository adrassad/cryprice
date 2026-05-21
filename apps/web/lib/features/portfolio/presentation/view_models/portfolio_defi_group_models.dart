import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_price_status.dart';

/// Wallet-scoped DeFi position row for grouped DeBank-style display.
class PortfolioProtocolPositionView {
  const PortfolioProtocolPositionView({
    required this.protocol,
    required this.protocolName,
    required this.networkId,
    required this.network,
    required this.networkName,
    required this.underlyingSymbol,
    required this.tokenSymbol,
    required this.tokenRole,
    required this.positionSide,
    required this.debtType,
    required this.priceUsd,
    required this.priceStatus,
    required this.walletId,
    required this.walletAddress,
    required this.walletLabel,
    required this.amount,
    required this.valueUsd,
    this.logoUrl,
  });

  final String protocol;
  final String protocolName;
  final int networkId;
  final String network;
  final String networkName;
  final String underlyingSymbol;
  final String tokenSymbol;
  final String tokenRole;
  final PortfolioPositionSide positionSide;
  final PortfolioDebtType? debtType;
  final String? priceUsd;
  final PortfolioPriceStatus priceStatus;
  final String walletId;
  final String walletAddress;
  final String? walletLabel;
  final String? amount;
  final String? valueUsd;
  final String? logoUrl;
}

/// protocol → network → wallet group with supplied and borrowed sides.
class PortfolioDefiNetworkWalletGroupView {
  const PortfolioDefiNetworkWalletGroupView({
    required this.protocol,
    required this.protocolName,
    required this.networkId,
    required this.network,
    required this.networkName,
    required this.walletId,
    required this.walletAddress,
    required this.walletLabel,
    required this.healthFactor,
    required this.supplied,
    required this.borrowed,
  });

  final String protocol;
  final String protocolName;
  final int networkId;
  final String network;
  final String networkName;
  final String walletId;
  final String walletAddress;
  final String? walletLabel;
  final PortfolioPositionHealth? healthFactor;
  final List<PortfolioProtocolPositionView> supplied;
  final List<PortfolioProtocolPositionView> borrowed;
}

/// Top-level DeFi protocol bucket for grouped portfolio display.
class PortfolioDefiProtocolGroup {
  const PortfolioDefiProtocolGroup({
    required this.protocol,
    required this.protocolName,
    required this.category,
    required this.totalValueUsd,
    required this.suppliedValueUsd,
    required this.borrowedValueUsd,
    required this.netValueUsd,
    required this.networkWalletGroups,
  });

  final String protocol;
  final String protocolName;
  final String category;
  final String? totalValueUsd;
  final String? suppliedValueUsd;
  final String? borrowedValueUsd;
  final String? netValueUsd;
  final List<PortfolioDefiNetworkWalletGroupView> networkWalletGroups;
}

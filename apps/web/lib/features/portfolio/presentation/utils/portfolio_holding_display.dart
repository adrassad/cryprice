import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_formatters.dart';

String portfolioHoldingSymbol(PortfolioHolding holding) {
  final symbol = holding.symbol.trim();
  if (symbol.isNotEmpty) {
    return symbol;
  }
  final assetSymbol = holding.assetSymbol.trim();
  if (assetSymbol.isNotEmpty) {
    return assetSymbol;
  }
  return holding.assetId;
}

String portfolioHoldingNetworkName(PortfolioHolding holding) {
  final networkName = holding.networkName.trim();
  if (networkName.isNotEmpty) {
    return networkName;
  }
  return holding.network;
}

String? portfolioHoldingAddress(PortfolioHolding holding) {
  final assetAddress = holding.assetAddress?.trim();
  if (assetAddress != null && assetAddress.isNotEmpty) {
    return assetAddress;
  }
  final address = holding.address?.trim();
  if (address != null && address.isNotEmpty) {
    return address;
  }
  return null;
}

String formatPortfolioHoldingBalance(
  PortfolioHolding holding, {
  required String unavailableLabel,
}) {
  final symbol = portfolioHoldingSymbol(holding);
  final trimmed = holding.amount?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return unavailableLabel;
  }
  return formatPortfolioBalance(balance: trimmed, symbol: symbol);
}

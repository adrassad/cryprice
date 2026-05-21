import 'package:cryprice_frontend/core/widgets/token_icon.dart';
import 'package:flutter/material.dart';

/// Shared DeFi positions table layout constants.
abstract final class PortfolioDefiTableLayout {
  static const int assetFlex = 3;
  static const int balanceFlex = 2;
  static const int priceFlex = 2;
  static const int valueFlex = 2;

  static const double horizontalPadding = 12;
  static const double rowVerticalPadding = 10;
  static const double assetIconSize = 36;
}

/// Circular token icon placeholder used when no token logo is available.
class PortfolioDefiAssetAvatar extends StatelessWidget {
  const PortfolioDefiAssetAvatar({
    super.key,
    required this.symbol,
    this.logoUrl,
  });

  final String symbol;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    return TokenIcon(
      logoUrl: logoUrl,
      symbol: symbol,
      size: PortfolioDefiTableLayout.assetIconSize,
    );
  }
}

/// Subtle row separator for DeFi position tables.
class PortfolioDefiRowDivider extends StatelessWidget {
  const PortfolioDefiRowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.35),
    );
  }
}

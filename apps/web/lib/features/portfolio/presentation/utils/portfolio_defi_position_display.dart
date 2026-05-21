import 'package:cryprice_frontend/features/portfolio/presentation/view_models/portfolio_defi_group_models.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_formatters.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';

String portfolioDefiPositionViewSymbol(PortfolioProtocolPositionView position) {
  final underlying = position.underlyingSymbol.trim();
  if (underlying.isNotEmpty) {
    return underlying;
  }
  return position.tokenSymbol.trim();
}

String? portfolioDefiPositionViewTokenSymbol(PortfolioProtocolPositionView position) {
  final token = position.tokenSymbol.trim();
  final underlying = position.underlyingSymbol.trim();
  if (token.isEmpty || token == underlying) {
    return null;
  }
  return token;
}

String formatPortfolioDefiPositionViewBalance(
  PortfolioProtocolPositionView position, {
  required String unavailableLabel,
}) {
  final symbol = portfolioDefiPositionViewSymbol(position);
  final trimmed = position.amount?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return unavailableLabel;
  }
  return formatPortfolioBalance(balance: trimmed, symbol: symbol);
}

String portfolioProtocolCategoryLabel(AppLocalizations loc, String category) {
  final normalized = category.trim().toLowerCase();
  if (normalized.isEmpty) {
    return '';
  }
  return switch (normalized) {
    'lending' => loc.portfolioProtocolCategoryLending,
    _ => category.trim(),
  };
}

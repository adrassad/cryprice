import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_formatters.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';

/// Formats inbox alert [createdAt] using the same logic as alert cards.
String formatAlertEventDate(String createdAt, AppLocalizations loc) {
  return formatPortfolioUpdatedAt(
    createdAt,
    updatedNeverLabel: loc.portfolioUpdatedNever,
  );
}

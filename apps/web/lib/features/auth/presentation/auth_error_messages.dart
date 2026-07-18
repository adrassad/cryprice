import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';

/// Emitted when backend OAuth redirect returns `?gis_error=`.
const String kGoogleAuthRedirectFailedErrorCode = 'google_auth_redirect_failed';

String? resolveAuthErrorMessage(AppLocalizations loc, String? errorMessage) {
  if (errorMessage == null || errorMessage.isEmpty) {
    return null;
  }
  if (errorMessage == kGoogleAuthRedirectFailedErrorCode) {
    return loc.googleAuthRedirectFailed;
  }
  return errorMessage;
}

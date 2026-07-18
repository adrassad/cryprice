import 'package:cryprice_frontend/features/auth/presentation/widgets/login_google_cta_stub.dart'
    as stub_cta;
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Web: Material CTA that starts backend OAuth redirect in the current tab.
///
/// Legacy GIS popup button (`google_sign_in_web` `renderButton`) is not used for
/// production login because Chrome/Firefox popup/FedCM flows are unreliable.
Widget buildLoginGoogleCta({
  required AppLocalizations loc,
  required VoidCallback onPressed,
}) {
  return stub_cta.buildLoginGoogleCta(loc: loc, onPressed: onPressed);
}

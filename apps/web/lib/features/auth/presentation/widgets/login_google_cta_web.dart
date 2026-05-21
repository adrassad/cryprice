import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart' as gsi;

/// Web: official GIS button via [google_sign_in.renderButton].
Widget buildLoginGoogleCta({
  required AppLocalizations loc, // ignore: unused_parameter
  required VoidCallback onPressed, // ignore: unused_parameter
}) {
  return gsi.renderButton(
    configuration: gsi.GSIButtonConfiguration(
      minimumWidth: 280,
    ),
  );
}

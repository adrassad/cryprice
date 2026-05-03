import 'package:crypto_tracker_app/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart' as gsi;

/// Web: official GIS button via [google_sign_in.renderButton]; [onPressed] restarts the wait / retry.
Widget buildLoginGoogleCta({required AppLocalizations loc, required VoidCallback onPressed}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      gsi.renderButton(
        configuration: gsi.GSIButtonConfiguration(
          minimumWidth: 280,
        ),
      ),
      const SizedBox(height: 12),
      TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.refresh),
        label: Text(loc.signInWithGoogle),
      ),
    ],
  );
}

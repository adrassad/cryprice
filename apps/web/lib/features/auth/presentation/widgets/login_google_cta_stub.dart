import 'package:crypto_tracker_app/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// iOS, Android, desktop: custom Material button; Google Sign-In uses [getIdToken] via [signIn].
Widget buildLoginGoogleCta({required AppLocalizations loc, required VoidCallback onPressed}) {
  return FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: Text(
      loc.signInWithGoogle,
      style: GoogleFonts.montserrat(fontSize: 16),
    ),
  );
}

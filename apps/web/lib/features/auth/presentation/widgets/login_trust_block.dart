import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Read-only safety bullets shared by login and account-access panels.
class LoginTrustBlock extends StatelessWidget {
  const LoginTrustBlock({
    super.key,
    required this.loc,
    this.compact = false,
    this.title,
    this.body,
  });

  final AppLocalizations loc;
  final bool compact;
  final String? title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextStyle titleStyle = GoogleFonts.montserrat(
      fontSize: compact ? 17 : 18,
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: colorScheme.onSurface,
    );
    final TextStyle bodyStyle = GoogleFonts.montserrat(
      fontSize: compact ? 14 : 15,
      height: 1.45,
      color: colorScheme.onSurfaceVariant,
    );
    final TextStyle bulletStyle = bodyStyle.copyWith(height: 1.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          title ?? loc.authTrustTitle,
          textAlign: TextAlign.center,
          style: titleStyle,
        ),
        SizedBox(height: compact ? 10 : 12),
        Text(
          body ?? loc.authTrustBody,
          textAlign: TextAlign.center,
          style: bodyStyle,
        ),
        SizedBox(height: compact ? 14 : 18),
        ...<String>[
          loc.authTrustNoWalletConnection,
          loc.authTrustNoSeedKeys,
          loc.authTrustNoSigningCustody,
          loc.authTrustPublicAddressesOnly,
        ].map(
          (String text) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: colorScheme.primary.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(text, style: bulletStyle),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:cryprice_frontend/features/crypto_price/presentation/pages/price_calculator_page.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// TODO(legacy): Remove after migration is fully verified. Authenticated flow is
// [AppAuthGate] → [AppShell] → [PriceCalculatorPage]. This wrapper is unused in
// production routing and kept only for temporary compatibility reference.

/// Legacy full-screen price UI (Scaffold + AppBar). Do not route here from [AppAuthGate].
class CryptoPage extends StatefulWidget {
  final VoidCallback onToggleLocale;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;
  final VoidCallback onOpenProfile;
  const CryptoPage({
    super.key,
    required this.onToggleLocale,
    required this.onToggleTheme,
    required this.onLogout,
    required this.onOpenProfile,
  });

  @override
  State<CryptoPage> createState() => _CryptoPageState();
}

class _CryptoPageState extends State<CryptoPage> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          loc.appTitle,
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: widget.onToggleLocale,
            tooltip: loc.switchLanguage,
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onToggleTheme,
            tooltip: loc.switchTheme,
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: widget.onOpenProfile,
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
            tooltip: loc.signOut,
          ),
        ],
      ),
      body: const SafeArea(
        child: PriceCalculatorPage(),
      ),
    );
  }
}

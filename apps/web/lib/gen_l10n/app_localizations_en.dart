// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Crypto Price';

  @override
  String get switchLanguage => 'Switch to Russian';

  @override
  String get switchTheme => 'Switch Theme';

  @override
  String get getPrice => 'Get Price';

  @override
  String get count => 'Count';

  @override
  String get coin1 => 'Coin 1';

  @override
  String get coin2 => 'Coin 2';

  @override
  String get enterTicker => 'Please enter a tickers and count.';

  @override
  String get error_fetch_failed => 'Failed to fetch price';

  @override
  String get error_no_internet => 'No internet connection';

  @override
  String get error_unknown => 'Unknown error occurred';

  @override
  String get resultsSectionCexTitle => 'CEX prices';

  @override
  String get resultsSectionCexSubtitle =>
      'Exchanges, indices, and off-chain API — one GET with ticker as last path segment';

  @override
  String get resultsSectionDexTitle => 'DEX prices';

  @override
  String get resultsSectionDexSubtitle =>
      'On-chain: one GET per symbol; last path segment is ticker, body lists all networks';

  @override
  String get resultsSectionDexEmpty => 'No on-chain quotes for this symbol.';

  @override
  String get priceTypeCex => 'CEX';

  @override
  String get priceTypeAggregated => 'Index / API';

  @override
  String get priceTypeOffchain => 'Off-chain';

  @override
  String get priceTypeOnchain => 'On-chain';

  @override
  String get unknownNetwork => 'Unknown network';

  @override
  String get labelNetwork => 'Network';

  @override
  String get labelSymbol => 'Symbol';

  @override
  String get labelCollected => 'Collected';

  @override
  String get labelPair => 'Pair';

  @override
  String get labelUpdated => 'Updated';

  @override
  String get sourceCryprice => 'CRYPRICE';

  @override
  String get typeDex => 'DEX';

  @override
  String get labelTokenAddress => 'Contract';

  @override
  String get statusFallback => 'Fallback';

  @override
  String get statusStale => 'Stale';

  @override
  String get emDash => '—';

  @override
  String resultsContextNetwork(String name) {
    return 'Net: $name';
  }

  @override
  String resultsContextAddress(String addr) {
    return 'Addr: $addr';
  }

  @override
  String resultsSymbolLine(String value) {
    return 'Symbol: $value';
  }

  @override
  String resultsNetworkLine(String value) {
    return 'Network: $value';
  }

  @override
  String resultsDexErrorLine(String source, String network, String error) {
    return '$source — $network\n$error';
  }

  @override
  String resultsCexErrorLine(String provider, String error) {
    return '$provider: ❌ $error';
  }

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get labelPrice => 'Price';

  @override
  String get authScreenTitle => 'Sign in';

  @override
  String get authScreenSubtitle =>
      'Sign in to continue. Your session is stored on this device.';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Log out';

  @override
  String get signInWithGoogle => 'Continue with Google';

  @override
  String get googleSignInWebTryAgain => 'Try again';
}

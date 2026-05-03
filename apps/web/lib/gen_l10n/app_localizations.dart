import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Crypto Price'**
  String get appTitle;

  /// No description provided for @switchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Switch to Russian'**
  String get switchLanguage;

  /// No description provided for @switchTheme.
  ///
  /// In en, this message translates to:
  /// **'Switch Theme'**
  String get switchTheme;

  /// No description provided for @getPrice.
  ///
  /// In en, this message translates to:
  /// **'Get Price'**
  String get getPrice;

  /// No description provided for @count.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// No description provided for @coin1.
  ///
  /// In en, this message translates to:
  /// **'Coin 1'**
  String get coin1;

  /// No description provided for @coin2.
  ///
  /// In en, this message translates to:
  /// **'Coin 2'**
  String get coin2;

  /// No description provided for @enterTicker.
  ///
  /// In en, this message translates to:
  /// **'Please enter a tickers and count.'**
  String get enterTicker;

  /// No description provided for @error_fetch_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch price'**
  String get error_fetch_failed;

  /// No description provided for @error_no_internet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get error_no_internet;

  /// No description provided for @error_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred'**
  String get error_unknown;

  /// No description provided for @resultsSectionCexTitle.
  ///
  /// In en, this message translates to:
  /// **'CEX prices'**
  String get resultsSectionCexTitle;

  /// No description provided for @resultsSectionCexSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Exchanges, indices, and off-chain API — one GET with ticker as last path segment'**
  String get resultsSectionCexSubtitle;

  /// No description provided for @resultsSectionDexTitle.
  ///
  /// In en, this message translates to:
  /// **'DEX prices'**
  String get resultsSectionDexTitle;

  /// No description provided for @resultsSectionDexSubtitle.
  ///
  /// In en, this message translates to:
  /// **'On-chain: one GET per symbol; last path segment is ticker, body lists all networks'**
  String get resultsSectionDexSubtitle;

  /// No description provided for @resultsSectionDexEmpty.
  ///
  /// In en, this message translates to:
  /// **'No on-chain quotes for this symbol.'**
  String get resultsSectionDexEmpty;

  /// No description provided for @priceTypeCex.
  ///
  /// In en, this message translates to:
  /// **'CEX'**
  String get priceTypeCex;

  /// No description provided for @priceTypeAggregated.
  ///
  /// In en, this message translates to:
  /// **'Index / API'**
  String get priceTypeAggregated;

  /// No description provided for @priceTypeOffchain.
  ///
  /// In en, this message translates to:
  /// **'Off-chain'**
  String get priceTypeOffchain;

  /// No description provided for @priceTypeOnchain.
  ///
  /// In en, this message translates to:
  /// **'On-chain'**
  String get priceTypeOnchain;

  /// No description provided for @unknownNetwork.
  ///
  /// In en, this message translates to:
  /// **'Unknown network'**
  String get unknownNetwork;

  /// No description provided for @labelNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get labelNetwork;

  /// No description provided for @labelSymbol.
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get labelSymbol;

  /// No description provided for @labelCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get labelCollected;

  /// No description provided for @labelPair.
  ///
  /// In en, this message translates to:
  /// **'Pair'**
  String get labelPair;

  /// No description provided for @labelUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get labelUpdated;

  /// No description provided for @sourceCryprice.
  ///
  /// In en, this message translates to:
  /// **'CRYPRICE'**
  String get sourceCryprice;

  /// No description provided for @typeDex.
  ///
  /// In en, this message translates to:
  /// **'DEX'**
  String get typeDex;

  /// No description provided for @labelTokenAddress.
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get labelTokenAddress;

  /// No description provided for @statusFallback.
  ///
  /// In en, this message translates to:
  /// **'Fallback'**
  String get statusFallback;

  /// No description provided for @statusStale.
  ///
  /// In en, this message translates to:
  /// **'Stale'**
  String get statusStale;

  /// No description provided for @emDash.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get emDash;

  /// No description provided for @resultsContextNetwork.
  ///
  /// In en, this message translates to:
  /// **'Net: {name}'**
  String resultsContextNetwork(String name);

  /// No description provided for @resultsContextAddress.
  ///
  /// In en, this message translates to:
  /// **'Addr: {addr}'**
  String resultsContextAddress(String addr);

  /// No description provided for @resultsSymbolLine.
  ///
  /// In en, this message translates to:
  /// **'Symbol: {value}'**
  String resultsSymbolLine(String value);

  /// No description provided for @resultsNetworkLine.
  ///
  /// In en, this message translates to:
  /// **'Network: {value}'**
  String resultsNetworkLine(String value);

  /// No description provided for @resultsDexErrorLine.
  ///
  /// In en, this message translates to:
  /// **'{source} — {network}\n{error}'**
  String resultsDexErrorLine(String source, String network, String error);

  /// No description provided for @resultsCexErrorLine.
  ///
  /// In en, this message translates to:
  /// **'{provider}: ❌ {error}'**
  String resultsCexErrorLine(String provider, String error);

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @labelPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get labelPrice;

  /// No description provided for @authScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authScreenTitle;

  /// No description provided for @authScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue. Your session is stored on this device.'**
  String get authScreenSubtitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get signOut;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get signInWithGoogle;

  /// No description provided for @googleSignInWebTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get googleSignInWebTryAgain;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

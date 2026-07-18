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
  /// **'CryPrice'**
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

  /// No description provided for @appSettingsMenu.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get appSettingsMenu;

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

  /// No description provided for @error_rate_limited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment and try again.'**
  String get error_rate_limited;

  /// No description provided for @error_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred'**
  String get error_unknown;

  /// No description provided for @error_invalid_count.
  ///
  /// In en, this message translates to:
  /// **'Count must be greater than zero'**
  String get error_invalid_count;

  /// No description provided for @resultsSectionCexTitle.
  ///
  /// In en, this message translates to:
  /// **'CEX prices'**
  String get resultsSectionCexTitle;

  /// No description provided for @resultsSectionCexSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Binance and Bybit — converted amount in Coin 2 via backend API'**
  String get resultsSectionCexSubtitle;

  /// No description provided for @resultsCexConvertHint.
  ///
  /// In en, this message translates to:
  /// **'{count} × {coin1} → {coin2}'**
  String resultsCexConvertHint(String count, String coin1, String coin2);

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
  /// **'CryPrice account access'**
  String get authScreenTitle;

  /// No description provided for @authScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use Google only for read-only dashboard access.'**
  String get authScreenSubtitle;

  /// No description provided for @authTrustTitle.
  ///
  /// In en, this message translates to:
  /// **'CryPrice is read-only.'**
  String get authTrustTitle;

  /// No description provided for @authTrustBody.
  ///
  /// In en, this message translates to:
  /// **'Use Google only to access your CryPrice dashboard.'**
  String get authTrustBody;

  /// No description provided for @authTrustNoWalletConnection.
  ///
  /// In en, this message translates to:
  /// **'No wallet connection'**
  String get authTrustNoWalletConnection;

  /// No description provided for @authTrustNoSeedKeys.
  ///
  /// In en, this message translates to:
  /// **'No seed phrases or private keys'**
  String get authTrustNoSeedKeys;

  /// No description provided for @authTrustNoSigningCustody.
  ///
  /// In en, this message translates to:
  /// **'No transaction signing or custody'**
  String get authTrustNoSigningCustody;

  /// No description provided for @authTrustPublicAddressesOnly.
  ///
  /// In en, this message translates to:
  /// **'Public addresses for monitoring only'**
  String get authTrustPublicAddressesOnly;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Account access'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get signOut;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Use Google for CryPrice account access'**
  String get signInWithGoogle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Account access required'**
  String get loginRequired;

  /// No description provided for @accountAccessRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'Use Google only to access your saved CryPrice dashboard data.'**
  String get accountAccessRequiredBody;

  /// No description provided for @profileLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get profileLoadFailed;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @thresholdHf.
  ///
  /// In en, this message translates to:
  /// **'Threshold HF'**
  String get thresholdHf;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @walletsTitle.
  ///
  /// In en, this message translates to:
  /// **'Public addresses'**
  String get walletsTitle;

  /// No description provided for @walletsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No public addresses added yet'**
  String get walletsEmpty;

  /// No description provided for @addWallet.
  ///
  /// In en, this message translates to:
  /// **'Add public address'**
  String get addWallet;

  /// No description provided for @walletAddress.
  ///
  /// In en, this message translates to:
  /// **'Public address'**
  String get walletAddress;

  /// No description provided for @walletLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get walletLabel;

  /// No description provided for @editWalletLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit label'**
  String get editWalletLabel;

  /// No description provided for @deleteWallet.
  ///
  /// In en, this message translates to:
  /// **'Remove monitored address'**
  String get deleteWallet;

  /// No description provided for @deleteWalletConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this monitored address from CryPrice?'**
  String get deleteWalletConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @walletAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Public address is required'**
  String get walletAddressRequired;

  /// No description provided for @walletAddressStartWith0x.
  ///
  /// In en, this message translates to:
  /// **'Address should start with 0x'**
  String get walletAddressStartWith0x;

  /// No description provided for @walletAddressLengthHint.
  ///
  /// In en, this message translates to:
  /// **'Expected EVM address length: 42 symbols'**
  String get walletAddressLengthHint;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @telegramId.
  ///
  /// In en, this message translates to:
  /// **'Telegram ID'**
  String get telegramId;

  /// No description provided for @profileTelegramTitle.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get profileTelegramTitle;

  /// No description provided for @profileTelegramLinked.
  ///
  /// In en, this message translates to:
  /// **'Telegram notifications linked'**
  String get profileTelegramLinked;

  /// No description provided for @profileTelegramLinkPrompt.
  ///
  /// In en, this message translates to:
  /// **'Link Telegram for optional notifications only.'**
  String get profileTelegramLinkPrompt;

  /// No description provided for @profileTelegramLinkButton.
  ///
  /// In en, this message translates to:
  /// **'Link Telegram for optional notifications'**
  String get profileTelegramLinkButton;

  /// No description provided for @profileTelegramSafetyNote.
  ///
  /// In en, this message translates to:
  /// **'Telegram is optional and never receives seed phrases, private keys, or wallet access.'**
  String get profileTelegramSafetyNote;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdatedSuccess;

  /// No description provided for @publicAddressAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Public address added'**
  String get publicAddressAddedSuccess;

  /// No description provided for @publicAddressLabelUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Address label updated'**
  String get publicAddressLabelUpdatedSuccess;

  /// No description provided for @publicAddressRemovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Monitored address removed'**
  String get publicAddressRemovedSuccess;

  /// No description provided for @profileTelegramLinkCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Telegram link created'**
  String get profileTelegramLinkCreatedSuccess;

  /// No description provided for @profileUserIdLabel.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get profileUserIdLabel;

  /// No description provided for @profileHfAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Factor Alerts'**
  String get profileHfAlertsTitle;

  /// No description provided for @profileHfAlertsDescription.
  ///
  /// In en, this message translates to:
  /// **'Notify me when my DeFi Health Factor drops below this threshold.'**
  String get profileHfAlertsDescription;

  /// No description provided for @profileHfAlertsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get profileHfAlertsEnabled;

  /// No description provided for @profileHfAlertsHelper.
  ///
  /// In en, this message translates to:
  /// **'Alerts trigger when HF crosses the threshold, not while it simply stays below it.'**
  String get profileHfAlertsHelper;

  /// No description provided for @profileHfAlertsTelegramWarning.
  ///
  /// In en, this message translates to:
  /// **'Telegram notifications are not linked. Alert settings will still be saved in the app, but optional Telegram notifications require linking.'**
  String get profileHfAlertsTelegramWarning;

  /// No description provided for @profileHfAlertsLegacySyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Alert rule saved, but legacy profile threshold sync failed.'**
  String get profileHfAlertsLegacySyncFailed;

  /// No description provided for @profileHfAlertsSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Alert settings saved'**
  String get profileHfAlertsSaveSuccess;

  /// No description provided for @profileHfThresholdRangeError.
  ///
  /// In en, this message translates to:
  /// **'Health Factor threshold must be between {min} and {max}'**
  String profileHfThresholdRangeError(String min, String max);

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get emailVerified;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdAt;

  /// No description provided for @portfolioTitle.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get portfolioTitle;

  /// No description provided for @portfolioTotalValue.
  ///
  /// In en, this message translates to:
  /// **'Total value'**
  String get portfolioTotalValue;

  /// No description provided for @portfolioNetValue.
  ///
  /// In en, this message translates to:
  /// **'Net value'**
  String get portfolioNetValue;

  /// No description provided for @portfolioWalletValue.
  ///
  /// In en, this message translates to:
  /// **'On-chain value'**
  String get portfolioWalletValue;

  /// No description provided for @portfolioSuppliedValue.
  ///
  /// In en, this message translates to:
  /// **'Supplied value'**
  String get portfolioSuppliedValue;

  /// No description provided for @portfolioBorrowedValue.
  ///
  /// In en, this message translates to:
  /// **'Borrowed / debt'**
  String get portfolioBorrowedValue;

  /// No description provided for @portfolioGrossValue.
  ///
  /// In en, this message translates to:
  /// **'Gross value'**
  String get portfolioGrossValue;

  /// No description provided for @portfolioHealthFactor.
  ///
  /// In en, this message translates to:
  /// **'Health Factor'**
  String get portfolioHealthFactor;

  /// No description provided for @portfolioNoBorrowRisk.
  ///
  /// In en, this message translates to:
  /// **'No borrow risk'**
  String get portfolioNoBorrowRisk;

  /// No description provided for @portfolioHealthFactorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Health Factor unavailable'**
  String get portfolioHealthFactorUnavailable;

  /// No description provided for @portfolioAllocation.
  ///
  /// In en, this message translates to:
  /// **'Allocation'**
  String get portfolioAllocation;

  /// No description provided for @portfolioAllocationAssets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get portfolioAllocationAssets;

  /// No description provided for @portfolioAllocationDebts.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get portfolioAllocationDebts;

  /// No description provided for @portfolioAllocationProtocols.
  ///
  /// In en, this message translates to:
  /// **'Protocols'**
  String get portfolioAllocationProtocols;

  /// No description provided for @portfolioAllocationNetworks.
  ///
  /// In en, this message translates to:
  /// **'Networks'**
  String get portfolioAllocationNetworks;

  /// No description provided for @portfolioNoAllocationData.
  ///
  /// In en, this message translates to:
  /// **'No allocation data'**
  String get portfolioNoAllocationData;

  /// No description provided for @portfolioNoDebtPositions.
  ///
  /// In en, this message translates to:
  /// **'No debt positions'**
  String get portfolioNoDebtPositions;

  /// No description provided for @portfolioNoProtocolAllocation.
  ///
  /// In en, this message translates to:
  /// **'No protocol allocation'**
  String get portfolioNoProtocolAllocation;

  /// No description provided for @portfolioNoNetworkAllocation.
  ///
  /// In en, this message translates to:
  /// **'No network allocation'**
  String get portfolioNoNetworkAllocation;

  /// No description provided for @portfolioAllocationOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get portfolioAllocationOther;

  /// No description provided for @portfolioHealthFactorUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'HF updated: {date}'**
  String portfolioHealthFactorUpdatedAt(String date);

  /// No description provided for @portfolioStaleData.
  ///
  /// In en, this message translates to:
  /// **'Stale data'**
  String get portfolioStaleData;

  /// No description provided for @portfolioSafe.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get portfolioSafe;

  /// No description provided for @portfolioWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get portfolioWatch;

  /// No description provided for @portfolioWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get portfolioWarning;

  /// No description provided for @portfolioAtRisk.
  ///
  /// In en, this message translates to:
  /// **'At risk'**
  String get portfolioAtRisk;

  /// No description provided for @portfolioLiquidationRisk.
  ///
  /// In en, this message translates to:
  /// **'Liquidation risk'**
  String get portfolioLiquidationRisk;

  /// No description provided for @portfolioUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get portfolioUnknown;

  /// No description provided for @portfolioOverviewScopeWalletFilter.
  ///
  /// In en, this message translates to:
  /// **'Totals reflect the selected address across all protocols.'**
  String get portfolioOverviewScopeWalletFilter;

  /// No description provided for @portfolioOverviewScopeProtocolWallet.
  ///
  /// In en, this message translates to:
  /// **'Totals reflect the selected address. Protocol-specific address totals are shown in the DeFi groups below.'**
  String get portfolioOverviewScopeProtocolWallet;

  /// No description provided for @portfolioWalletHoldings.
  ///
  /// In en, this message translates to:
  /// **'On-chain holdings'**
  String get portfolioWalletHoldings;

  /// No description provided for @portfolioNoWalletHoldings.
  ///
  /// In en, this message translates to:
  /// **'No on-chain holdings'**
  String get portfolioNoWalletHoldings;

  /// No description provided for @portfolioDefiPositions.
  ///
  /// In en, this message translates to:
  /// **'DeFi Positions'**
  String get portfolioDefiPositions;

  /// No description provided for @portfolioProtocolCategoryLending.
  ///
  /// In en, this message translates to:
  /// **'Lending'**
  String get portfolioProtocolCategoryLending;

  /// No description provided for @portfolioSupplied.
  ///
  /// In en, this message translates to:
  /// **'Supplied'**
  String get portfolioSupplied;

  /// No description provided for @portfolioBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Borrowed'**
  String get portfolioBorrowed;

  /// No description provided for @portfolioDebt.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get portfolioDebt;

  /// No description provided for @portfolioLiability.
  ///
  /// In en, this message translates to:
  /// **'Liability — reflected in net value'**
  String get portfolioLiability;

  /// No description provided for @portfolioNoDefiPositions.
  ///
  /// In en, this message translates to:
  /// **'No DeFi positions yet'**
  String get portfolioNoDefiPositions;

  /// No description provided for @portfolioNoSuppliedPositions.
  ///
  /// In en, this message translates to:
  /// **'No supplied positions'**
  String get portfolioNoSuppliedPositions;

  /// No description provided for @portfolioNoBorrowedPositions.
  ///
  /// In en, this message translates to:
  /// **'No borrowed positions'**
  String get portfolioNoBorrowedPositions;

  /// No description provided for @portfolioVariableDebt.
  ///
  /// In en, this message translates to:
  /// **'Variable debt'**
  String get portfolioVariableDebt;

  /// No description provided for @portfolioStableDebt.
  ///
  /// In en, this message translates to:
  /// **'Stable debt'**
  String get portfolioStableDebt;

  /// No description provided for @portfolioRiskDetails.
  ///
  /// In en, this message translates to:
  /// **'Risk Details'**
  String get portfolioRiskDetails;

  /// No description provided for @portfolioThreshold.
  ///
  /// In en, this message translates to:
  /// **'Threshold'**
  String get portfolioThreshold;

  /// No description provided for @portfolioValueUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Value unavailable'**
  String get portfolioValueUnavailable;

  /// No description provided for @portfolioWallets.
  ///
  /// In en, this message translates to:
  /// **'Public addresses'**
  String get portfolioWallets;

  /// No description provided for @portfolioAssets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get portfolioAssets;

  /// No description provided for @portfolioNetworks.
  ///
  /// In en, this message translates to:
  /// **'Networks'**
  String get portfolioNetworks;

  /// No description provided for @portfolioLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get portfolioLastUpdated;

  /// No description provided for @portfolioPriceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Price unavailable'**
  String get portfolioPriceUnavailable;

  /// No description provided for @portfolioPriceStale.
  ///
  /// In en, this message translates to:
  /// **'Price stale'**
  String get portfolioPriceStale;

  /// No description provided for @portfolioPriceStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown price status'**
  String get portfolioPriceStatusUnknown;

  /// No description provided for @portfolioNoAssets.
  ///
  /// In en, this message translates to:
  /// **'No portfolio assets yet'**
  String get portfolioNoAssets;

  /// No description provided for @portfolioEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add a public address in Profile, then refresh Portfolio.'**
  String get portfolioEmptyHint;

  /// No description provided for @portfolioLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load portfolio'**
  String get portfolioLoadFailed;

  /// No description provided for @portfolioRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get portfolioRetry;

  /// No description provided for @portfolioPullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get portfolioPullToRefresh;

  /// No description provided for @portfolioExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get portfolioExportPdf;

  /// No description provided for @portfolioExportPdfShort.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get portfolioExportPdfShort;

  /// No description provided for @portfolioExportPdfPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing PDF...'**
  String get portfolioExportPdfPreparing;

  /// No description provided for @portfolioExportPdfFailed.
  ///
  /// In en, this message translates to:
  /// **'PDF export failed'**
  String get portfolioExportPdfFailed;

  /// No description provided for @portfolioExportPdfDownloaded.
  ///
  /// In en, this message translates to:
  /// **'PDF report downloaded'**
  String get portfolioExportPdfDownloaded;

  /// No description provided for @portfolioNetworkTotal.
  ///
  /// In en, this message translates to:
  /// **'Network total'**
  String get portfolioNetworkTotal;

  /// No description provided for @portfolioTokenBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get portfolioTokenBalance;

  /// No description provided for @portfolioTokenPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get portfolioTokenPrice;

  /// No description provided for @portfolioTokenValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get portfolioTokenValue;

  /// No description provided for @portfolioCurrentPrice.
  ///
  /// In en, this message translates to:
  /// **'Current Price'**
  String get portfolioCurrentPrice;

  /// No description provided for @portfolioUsdValue.
  ///
  /// In en, this message translates to:
  /// **'USD Value'**
  String get portfolioUsdValue;

  /// No description provided for @portfolioWalletBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Address breakdown'**
  String get portfolioWalletBreakdown;

  /// No description provided for @portfolioSyncedAt.
  ///
  /// In en, this message translates to:
  /// **'Synced at'**
  String get portfolioSyncedAt;

  /// No description provided for @portfolioBlockNumber.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get portfolioBlockNumber;

  /// No description provided for @portfolioAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get portfolioAddress;

  /// No description provided for @portfolioUpdatedNever.
  ///
  /// In en, this message translates to:
  /// **'Never updated'**
  String get portfolioUpdatedNever;

  /// No description provided for @portfolioAllProtocols.
  ///
  /// In en, this message translates to:
  /// **'All protocols'**
  String get portfolioAllProtocols;

  /// No description provided for @portfolioAllWallets.
  ///
  /// In en, this message translates to:
  /// **'All addresses'**
  String get portfolioAllWallets;

  /// No description provided for @portfolioWallet.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get portfolioWallet;

  /// No description provided for @portfolioProtocols.
  ///
  /// In en, this message translates to:
  /// **'Protocols'**
  String get portfolioProtocols;

  /// No description provided for @portfolioTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get portfolioTotal;

  /// No description provided for @navPriceCalculator.
  ///
  /// In en, this message translates to:
  /// **'Prices'**
  String get navPriceCalculator;

  /// No description provided for @navPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get navPortfolio;

  /// No description provided for @navAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get navAlerts;

  /// No description provided for @navHealthFactorCalculator.
  ///
  /// In en, this message translates to:
  /// **'HF Calculator'**
  String get navHealthFactorCalculator;

  /// No description provided for @alertsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No alerts yet'**
  String get alertsEmpty;

  /// No description provided for @alertsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading alerts…'**
  String get alertsLoading;

  /// No description provided for @alertsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load alerts. Try again later.'**
  String get alertsError;

  /// No description provided for @alertsNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server. Check your connection and try again.'**
  String get alertsNetworkError;

  /// No description provided for @alertsRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh alerts. Pull down to try again.'**
  String get alertsRefreshFailed;

  /// No description provided for @alertsMarkReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not mark alert as read. Try again.'**
  String get alertsMarkReadFailed;

  /// No description provided for @alertsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get alertsMarkAllRead;

  /// No description provided for @alertsMarkAllReadTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mark all alerts as read'**
  String get alertsMarkAllReadTooltip;

  /// No description provided for @alertsMarkAllReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not mark all alerts as read. Try again.'**
  String get alertsMarkAllReadFailed;

  /// No description provided for @alertsMarkingAllRead.
  ///
  /// In en, this message translates to:
  /// **'Marking as read…'**
  String get alertsMarkingAllRead;

  /// No description provided for @alertsUnreadBadgeMax.
  ///
  /// In en, this message translates to:
  /// **'99+'**
  String get alertsUnreadBadgeMax;

  /// No description provided for @alertsSeverityUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get alertsSeverityUnknown;

  /// No description provided for @alertsScopeUnknown.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get alertsScopeUnknown;

  /// No description provided for @alertsUnsupportedType.
  ///
  /// In en, this message translates to:
  /// **'Unsupported alert type'**
  String get alertsUnsupportedType;

  /// No description provided for @alertsMarkReadHint.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get alertsMarkReadHint;

  /// No description provided for @alertsCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get alertsCopy;

  /// No description provided for @alertsCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Alert copied to clipboard'**
  String get alertsCopiedToClipboard;

  /// No description provided for @alertsCopyFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not copy alert'**
  String get alertsCopyFailed;

  /// No description provided for @alertsCopiedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy alert summary'**
  String get alertsCopiedTooltip;

  /// No description provided for @alertsRiskNewsDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Rule-based risk signal, not financial advice'**
  String get alertsRiskNewsDisclaimer;

  /// No description provided for @alertsRiskNewsScopeGlobal.
  ///
  /// In en, this message translates to:
  /// **'🌍 Global DeFi Risk'**
  String get alertsRiskNewsScopeGlobal;

  /// No description provided for @alertsRiskNewsScopeExposure.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Your exposure detected'**
  String get alertsRiskNewsScopeExposure;

  /// No description provided for @alertsRiskNewsScopeAdminOnly.
  ///
  /// In en, this message translates to:
  /// **'🛠 Internal/Admin'**
  String get alertsRiskNewsScopeAdminOnly;

  /// No description provided for @alertsRiskNewsSeverityCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get alertsRiskNewsSeverityCritical;

  /// No description provided for @alertsRiskNewsSeverityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get alertsRiskNewsSeverityHigh;

  /// No description provided for @alertsRiskNewsSeverityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get alertsRiskNewsSeverityMedium;

  /// No description provided for @alertsRiskNewsSeverityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get alertsRiskNewsSeverityLow;

  /// No description provided for @alertsRiskNewsSeverityWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get alertsRiskNewsSeverityWarning;

  /// No description provided for @alertsRiskNewsSeverityInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get alertsRiskNewsSeverityInfo;

  /// No description provided for @alertsRiskNewsSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get alertsRiskNewsSource;

  /// No description provided for @alertsRiskNewsSourceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Source link unavailable'**
  String get alertsRiskNewsSourceUnavailable;

  /// No description provided for @alertsRiskNewsSourceOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open source link'**
  String get alertsRiskNewsSourceOpenFailed;

  /// No description provided for @alertsRiskNewsGlobalReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get alertsRiskNewsGlobalReason;

  /// No description provided for @alertsRiskNewsMatchedAsset.
  ///
  /// In en, this message translates to:
  /// **'Matched asset'**
  String get alertsRiskNewsMatchedAsset;

  /// No description provided for @alertsRiskNewsMatchedProtocol.
  ///
  /// In en, this message translates to:
  /// **'Matched protocol'**
  String get alertsRiskNewsMatchedProtocol;

  /// No description provided for @alertsRiskNewsMatchedChain.
  ///
  /// In en, this message translates to:
  /// **'Matched chain'**
  String get alertsRiskNewsMatchedChain;

  /// No description provided for @alertsRiskNewsMatchConfidence.
  ///
  /// In en, this message translates to:
  /// **'Match confidence: {value}'**
  String alertsRiskNewsMatchConfidence(String value);

  /// No description provided for @alertsRiskNewsAffectedAssets.
  ///
  /// In en, this message translates to:
  /// **'Affected assets'**
  String get alertsRiskNewsAffectedAssets;

  /// No description provided for @alertsRiskNewsAffectedProtocols.
  ///
  /// In en, this message translates to:
  /// **'Affected protocols'**
  String get alertsRiskNewsAffectedProtocols;

  /// No description provided for @alertsRiskNewsAffectedChains.
  ///
  /// In en, this message translates to:
  /// **'Affected chains'**
  String get alertsRiskNewsAffectedChains;

  /// No description provided for @alertsHfAlertTypeBreach.
  ///
  /// In en, this message translates to:
  /// **'HF breach'**
  String get alertsHfAlertTypeBreach;

  /// No description provided for @alertsHfAlertTypeRecovery.
  ///
  /// In en, this message translates to:
  /// **'HF recovery'**
  String get alertsHfAlertTypeRecovery;

  /// No description provided for @alertsHfWallet.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get alertsHfWallet;

  /// No description provided for @alertsHfProtocol.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get alertsHfProtocol;

  /// No description provided for @alertsHfNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get alertsHfNetwork;

  /// No description provided for @alertsHfThreshold.
  ///
  /// In en, this message translates to:
  /// **'Threshold'**
  String get alertsHfThreshold;

  /// No description provided for @alertsHfThresholdLabel.
  ///
  /// In en, this message translates to:
  /// **'🎯 Alert threshold'**
  String get alertsHfThresholdLabel;

  /// No description provided for @alertsHfLiquidationHeadline.
  ///
  /// In en, this message translates to:
  /// **'Liquidation'**
  String get alertsHfLiquidationHeadline;

  /// No description provided for @alertsHfLiquidationExplanation.
  ///
  /// In en, this message translates to:
  /// **'Critical situation: your position may be liquidated'**
  String get alertsHfLiquidationExplanation;

  /// No description provided for @alertsHfBelowAlertThreshold.
  ///
  /// In en, this message translates to:
  /// **'Health Factor below your alert threshold'**
  String get alertsHfBelowAlertThreshold;

  /// No description provided for @alertsHfRecoveredAboveAlertThreshold.
  ///
  /// In en, this message translates to:
  /// **'Health Factor recovered above your alert threshold'**
  String get alertsHfRecoveredAboveAlertThreshold;

  /// No description provided for @alertsHfCriticalHeadline.
  ///
  /// In en, this message translates to:
  /// **'Health Factor critical'**
  String get alertsHfCriticalHeadline;

  /// No description provided for @alertsHfRecoveryHeadline.
  ///
  /// In en, this message translates to:
  /// **'Health Factor recovered'**
  String get alertsHfRecoveryHeadline;

  /// No description provided for @alertsHfPreviousHf.
  ///
  /// In en, this message translates to:
  /// **'Previous HF'**
  String get alertsHfPreviousHf;

  /// No description provided for @alertsHfCurrentHf.
  ///
  /// In en, this message translates to:
  /// **'Current HF'**
  String get alertsHfCurrentHf;

  /// No description provided for @alertsHfNetworkProtocol.
  ///
  /// In en, this message translates to:
  /// **'Network · Protocol'**
  String get alertsHfNetworkProtocol;

  /// No description provided for @alertsHfMovementChanged.
  ///
  /// In en, this message translates to:
  /// **'Health Factor changed'**
  String get alertsHfMovementChanged;

  /// No description provided for @alertsHfMovementImproved.
  ///
  /// In en, this message translates to:
  /// **'Health Factor improved'**
  String get alertsHfMovementImproved;

  /// No description provided for @alertsHfMovementDecreased.
  ///
  /// In en, this message translates to:
  /// **'Health Factor decreased'**
  String get alertsHfMovementDecreased;

  /// No description provided for @alertsHfMovementUnchanged.
  ///
  /// In en, this message translates to:
  /// **'Health Factor unchanged'**
  String get alertsHfMovementUnchanged;

  /// No description provided for @hfCalcTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Factor Calculator'**
  String get hfCalcTitle;

  /// No description provided for @hfCalcSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Estimate your DeFi lending health factor using live market data.'**
  String get hfCalcSubtitle;

  /// No description provided for @hfCalcProtocol.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get hfCalcProtocol;

  /// No description provided for @hfCalcSelectProtocol.
  ///
  /// In en, this message translates to:
  /// **'Select protocol'**
  String get hfCalcSelectProtocol;

  /// No description provided for @hfCalcNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get hfCalcNetwork;

  /// No description provided for @hfCalcSelectNetwork.
  ///
  /// In en, this message translates to:
  /// **'Select network'**
  String get hfCalcSelectNetwork;

  /// No description provided for @hfCalcSupplySection.
  ///
  /// In en, this message translates to:
  /// **'Supply / Collateral'**
  String get hfCalcSupplySection;

  /// No description provided for @hfCalcBorrowSection.
  ///
  /// In en, this message translates to:
  /// **'Borrow'**
  String get hfCalcBorrowSection;

  /// No description provided for @hfCalcAddSupply.
  ///
  /// In en, this message translates to:
  /// **'Add supply'**
  String get hfCalcAddSupply;

  /// No description provided for @hfCalcAddBorrow.
  ///
  /// In en, this message translates to:
  /// **'Add borrow'**
  String get hfCalcAddBorrow;

  /// No description provided for @hfCalcAsset.
  ///
  /// In en, this message translates to:
  /// **'Asset'**
  String get hfCalcAsset;

  /// No description provided for @hfCalcSelectAsset.
  ///
  /// In en, this message translates to:
  /// **'Select asset'**
  String get hfCalcSelectAsset;

  /// No description provided for @hfCalcAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get hfCalcAmount;

  /// No description provided for @hfCalcUseAsCollateral.
  ///
  /// In en, this message translates to:
  /// **'Use as collateral'**
  String get hfCalcUseAsCollateral;

  /// No description provided for @hfCalcCalculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get hfCalcCalculate;

  /// No description provided for @hfCalcCalculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating…'**
  String get hfCalcCalculating;

  /// No description provided for @hfCalcResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get hfCalcResult;

  /// No description provided for @hfCalcHealthFactor.
  ///
  /// In en, this message translates to:
  /// **'Health Factor'**
  String get hfCalcHealthFactor;

  /// No description provided for @hfCalcRiskLevel.
  ///
  /// In en, this message translates to:
  /// **'Risk level'**
  String get hfCalcRiskLevel;

  /// No description provided for @hfCalcCollateralUsd.
  ///
  /// In en, this message translates to:
  /// **'Collateral (USD)'**
  String get hfCalcCollateralUsd;

  /// No description provided for @hfCalcCollateralWeightedUsd.
  ///
  /// In en, this message translates to:
  /// **'Weighted collateral (USD)'**
  String get hfCalcCollateralWeightedUsd;

  /// No description provided for @hfCalcBorrowUsd.
  ///
  /// In en, this message translates to:
  /// **'Borrow (USD)'**
  String get hfCalcBorrowUsd;

  /// No description provided for @hfCalcWarnings.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get hfCalcWarnings;

  /// No description provided for @hfCalcBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Position breakdown'**
  String get hfCalcBreakdown;

  /// No description provided for @hfCalcNoResultTitle.
  ///
  /// In en, this message translates to:
  /// **'No result yet'**
  String get hfCalcNoResultTitle;

  /// No description provided for @hfCalcNoResultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter supply and/or borrow positions, then calculate.'**
  String get hfCalcNoResultSubtitle;

  /// No description provided for @hfCalcLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading calculator…'**
  String get hfCalcLoading;

  /// No description provided for @hfCalcErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load calculator'**
  String get hfCalcErrorTitle;

  /// No description provided for @hfCalcRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get hfCalcRetry;

  /// No description provided for @hfCalcUnauthenticatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Session expired'**
  String get hfCalcUnauthenticatedTitle;

  /// No description provided for @hfCalcUnauthenticatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Account access is required to calculate your health factor.'**
  String get hfCalcUnauthenticatedMessage;

  /// No description provided for @hfCalcNoMarkets.
  ///
  /// In en, this message translates to:
  /// **'No market reserves available for this network.'**
  String get hfCalcNoMarkets;

  /// No description provided for @hfCalcRemoveRow.
  ///
  /// In en, this message translates to:
  /// **'Remove row'**
  String get hfCalcRemoveRow;

  /// No description provided for @hfCalcNoProtocolsTitle.
  ///
  /// In en, this message translates to:
  /// **'No protocols available'**
  String get hfCalcNoProtocolsTitle;

  /// No description provided for @hfCalcNoProtocolsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Health factor protocols could not be loaded.'**
  String get hfCalcNoProtocolsSubtitle;

  /// No description provided for @hfCalcNoNetworksTitle.
  ///
  /// In en, this message translates to:
  /// **'No networks available'**
  String get hfCalcNoNetworksTitle;

  /// No description provided for @hfCalcNoNetworksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try another protocol or check back later.'**
  String get hfCalcNoNetworksSubtitle;

  /// No description provided for @hfCalcRiskNoDebt.
  ///
  /// In en, this message translates to:
  /// **'No debt'**
  String get hfCalcRiskNoDebt;

  /// No description provided for @hfCalcRiskSafer.
  ///
  /// In en, this message translates to:
  /// **'Safer'**
  String get hfCalcRiskSafer;

  /// No description provided for @hfCalcRiskModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get hfCalcRiskModerate;

  /// No description provided for @hfCalcRiskWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get hfCalcRiskWarning;

  /// No description provided for @hfCalcRiskHigh.
  ///
  /// In en, this message translates to:
  /// **'High risk'**
  String get hfCalcRiskHigh;

  /// No description provided for @hfCalcRiskCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get hfCalcRiskCritical;

  /// No description provided for @hfCalcRiskLiquidation.
  ///
  /// In en, this message translates to:
  /// **'Liquidation risk'**
  String get hfCalcRiskLiquidation;

  /// No description provided for @hfCalcRiskUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get hfCalcRiskUnknown;

  /// No description provided for @hfCalcCurrentPrice.
  ///
  /// In en, this message translates to:
  /// **'Current price'**
  String get hfCalcCurrentPrice;

  /// No description provided for @hfCalcMarketPrice.
  ///
  /// In en, this message translates to:
  /// **'Market price'**
  String get hfCalcMarketPrice;

  /// No description provided for @hfCalcUsedPrice.
  ///
  /// In en, this message translates to:
  /// **'Used price'**
  String get hfCalcUsedPrice;

  /// No description provided for @hfCalcCustomPrice.
  ///
  /// In en, this message translates to:
  /// **'Custom price (USD)'**
  String get hfCalcCustomPrice;

  /// No description provided for @hfCalcUseMarketPrice.
  ///
  /// In en, this message translates to:
  /// **'Use market price'**
  String get hfCalcUseMarketPrice;

  /// No description provided for @hfCalcSimulationOnly.
  ///
  /// In en, this message translates to:
  /// **'Used for simulation only'**
  String get hfCalcSimulationOnly;

  /// No description provided for @hfCalcPriceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Price unavailable'**
  String get hfCalcPriceUnavailable;

  /// No description provided for @hfCalcCustomPriceUsed.
  ///
  /// In en, this message translates to:
  /// **'Custom price used for simulation'**
  String get hfCalcCustomPriceUsed;

  /// No description provided for @hfCalcCustomPriceDiffers.
  ///
  /// In en, this message translates to:
  /// **'Custom price differs significantly from market price'**
  String get hfCalcCustomPriceDiffers;

  /// No description provided for @hfCalcPositionValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get hfCalcPositionValue;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @menuProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get menuProfile;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Account access'**
  String get logIn;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @appUpdateAvailable.
  ///
  /// In en, this message translates to:
  /// **'CryPrice was updated. Reload to continue safely.'**
  String get appUpdateAvailable;

  /// No description provided for @appUpdateReload.
  ///
  /// In en, this message translates to:
  /// **'Reload app'**
  String get appUpdateReload;

  /// No description provided for @appUpdateManualInstructions.
  ///
  /// In en, this message translates to:
  /// **'CryPrice could not refresh automatically. Close other tabs for this site, then reload the page or clear site data for app.cryprice.dev.'**
  String get appUpdateManualInstructions;

  /// No description provided for @authStaleRecoveryMessage.
  ///
  /// In en, this message translates to:
  /// **'CryPrice auth flow was updated. Reload the app and try again.'**
  String get authStaleRecoveryMessage;

  /// No description provided for @authStaleRecoveryReload.
  ///
  /// In en, this message translates to:
  /// **'Reload app'**
  String get authStaleRecoveryReload;

  /// No description provided for @googleAuthRedirectFailed.
  ///
  /// In en, this message translates to:
  /// **'Google account access was cancelled or failed. Please try again.'**
  String get googleAuthRedirectFailed;

  /// No description provided for @appCacheReset.
  ///
  /// In en, this message translates to:
  /// **'Reset app cache'**
  String get appCacheReset;

  /// No description provided for @appCacheResetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset app cache?'**
  String get appCacheResetConfirmTitle;

  /// No description provided for @appCacheResetConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will clear local app cache and reload CryPrice. You may need to access your account again.'**
  String get appCacheResetConfirmMessage;

  /// No description provided for @appCacheResetConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Reset and reload'**
  String get appCacheResetConfirmAction;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @localeEn.
  ///
  /// In en, this message translates to:
  /// **'EN'**
  String get localeEn;

  /// No description provided for @localeRu.
  ///
  /// In en, this message translates to:
  /// **'RU'**
  String get localeRu;

  /// No description provided for @editPriceInput.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get editPriceInput;

  /// No description provided for @priceInputSummary.
  ///
  /// In en, this message translates to:
  /// **'{coin1} / {coin2} · {count}'**
  String priceInputSummary(String coin1, String coin2, String count);
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

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

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login required'**
  String get loginRequired;

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
  /// **'Wallets'**
  String get walletsTitle;

  /// No description provided for @walletsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No wallets added yet'**
  String get walletsEmpty;

  /// No description provided for @addWallet.
  ///
  /// In en, this message translates to:
  /// **'Add wallet'**
  String get addWallet;

  /// No description provided for @walletAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
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
  /// **'Delete wallet'**
  String get deleteWallet;

  /// No description provided for @deleteWalletConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete this wallet?'**
  String get deleteWalletConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @walletAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Wallet address is required'**
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
  /// **'Telegram linked'**
  String get profileTelegramLinked;

  /// No description provided for @profileTelegramLinkPrompt.
  ///
  /// In en, this message translates to:
  /// **'Link Telegram to receive notifications.'**
  String get profileTelegramLinkPrompt;

  /// No description provided for @profileTelegramLinkButton.
  ///
  /// In en, this message translates to:
  /// **'Link Telegram'**
  String get profileTelegramLinkButton;

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
  /// **'Wallet value'**
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
  /// **'Totals reflect the selected wallet across all protocols.'**
  String get portfolioOverviewScopeWalletFilter;

  /// No description provided for @portfolioOverviewScopeProtocolWallet.
  ///
  /// In en, this message translates to:
  /// **'Totals reflect the selected wallet. Protocol-specific wallet totals are shown in the DeFi groups below.'**
  String get portfolioOverviewScopeProtocolWallet;

  /// No description provided for @portfolioWalletHoldings.
  ///
  /// In en, this message translates to:
  /// **'Wallet Holdings'**
  String get portfolioWalletHoldings;

  /// No description provided for @portfolioNoWalletHoldings.
  ///
  /// In en, this message translates to:
  /// **'No wallet holdings'**
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
  /// **'Wallets'**
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
  /// **'Add or sync a wallet from Profile, then refresh Portfolio.'**
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
  /// **'Wallet breakdown'**
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
  /// **'All wallets'**
  String get portfolioAllWallets;

  /// No description provided for @portfolioWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
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

  /// No description provided for @navHealthFactorCalculator.
  ///
  /// In en, this message translates to:
  /// **'HF Calculator'**
  String get navHealthFactorCalculator;

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
  /// **'Log in'**
  String get logIn;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

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

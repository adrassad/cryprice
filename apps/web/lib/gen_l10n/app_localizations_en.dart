// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CryPrice';

  @override
  String get switchLanguage => 'Switch to Russian';

  @override
  String get switchTheme => 'Switch Theme';

  @override
  String get appSettingsMenu => 'Settings';

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
  String get error_rate_limited =>
      'Too many requests. Please wait a moment and try again.';

  @override
  String get error_unknown => 'Unknown error occurred';

  @override
  String get error_invalid_count => 'Count must be greater than zero';

  @override
  String get resultsSectionCexTitle => 'CEX prices';

  @override
  String get resultsSectionCexSubtitle =>
      'Binance and Bybit — converted amount in Coin 2 via backend API';

  @override
  String resultsCexConvertHint(String count, String coin1, String coin2) {
    return '$count × $coin1 → $coin2';
  }

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
  String get authScreenTitle => 'CryPrice account access';

  @override
  String get authScreenSubtitle =>
      'Use Google only for read-only dashboard access.';

  @override
  String get authTrustTitle => 'CryPrice is read-only.';

  @override
  String get authTrustBody =>
      'Use Google only to access your CryPrice dashboard.';

  @override
  String get authTrustNoWalletConnection => 'No wallet connection';

  @override
  String get authTrustNoSeedKeys => 'No seed phrases or private keys';

  @override
  String get authTrustNoSigningCustody => 'No transaction signing or custody';

  @override
  String get authTrustPublicAddressesOnly =>
      'Public addresses for monitoring only';

  @override
  String get signIn => 'Account access';

  @override
  String get signOut => 'Log out';

  @override
  String get signInWithGoogle => 'Use Google for CryPrice account access';

  @override
  String get profileTitle => 'Profile';

  @override
  String get loginRequired => 'Account access required';

  @override
  String get accountAccessRequiredBody =>
      'Use Google only to access your saved CryPrice dashboard data.';

  @override
  String get profileLoadFailed => 'Failed to load profile';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get language => 'Language';

  @override
  String get thresholdHf => 'Threshold HF';

  @override
  String get username => 'Username';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get walletsTitle => 'Public addresses';

  @override
  String get walletsEmpty => 'No public addresses added yet';

  @override
  String get addWallet => 'Add public address';

  @override
  String get walletAddress => 'Public address';

  @override
  String get walletLabel => 'Label';

  @override
  String get editWalletLabel => 'Edit label';

  @override
  String get deleteWallet => 'Remove monitored address';

  @override
  String get deleteWalletConfirm =>
      'Remove this monitored address from CryPrice?';

  @override
  String get delete => 'Delete';

  @override
  String get walletAddressRequired => 'Public address is required';

  @override
  String get walletAddressStartWith0x => 'Address should start with 0x';

  @override
  String get walletAddressLengthHint =>
      'Expected EVM address length: 42 symbols';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get telegramId => 'Telegram ID';

  @override
  String get profileTelegramTitle => 'Telegram';

  @override
  String get profileTelegramLinked => 'Telegram notifications linked';

  @override
  String get profileTelegramLinkPrompt =>
      'Link Telegram for optional notifications only.';

  @override
  String get profileTelegramLinkButton =>
      'Link Telegram for optional notifications';

  @override
  String get profileTelegramSafetyNote =>
      'Telegram is optional and never receives seed phrases, private keys, or wallet access.';

  @override
  String get profileUpdatedSuccess => 'Profile updated';

  @override
  String get publicAddressAddedSuccess => 'Public address added';

  @override
  String get publicAddressLabelUpdatedSuccess => 'Address label updated';

  @override
  String get publicAddressRemovedSuccess => 'Monitored address removed';

  @override
  String get profileTelegramLinkCreatedSuccess => 'Telegram link created';

  @override
  String get profileUserIdLabel => 'ID';

  @override
  String get profileHfAlertsTitle => 'Health Factor Alerts';

  @override
  String get profileHfAlertsDescription =>
      'Notify me when my DeFi Health Factor drops below this threshold.';

  @override
  String get profileHfAlertsEnabled => 'Enabled';

  @override
  String get profileHfAlertsHelper =>
      'Alerts trigger when HF crosses the threshold, not while it simply stays below it.';

  @override
  String get profileHfAlertsTelegramWarning =>
      'Telegram notifications are not linked. Alert settings will still be saved in the app, but optional Telegram notifications require linking.';

  @override
  String get profileHfAlertsLegacySyncFailed =>
      'Alert rule saved, but legacy profile threshold sync failed.';

  @override
  String get profileHfAlertsSaveSuccess => 'Alert settings saved';

  @override
  String profileHfThresholdRangeError(String min, String max) {
    return 'Health Factor threshold must be between $min and $max';
  }

  @override
  String get email => 'Email';

  @override
  String get emailVerified => 'Email verified';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get createdAt => 'Created';

  @override
  String get portfolioTitle => 'Portfolio';

  @override
  String get portfolioTotalValue => 'Total value';

  @override
  String get portfolioNetValue => 'Net value';

  @override
  String get portfolioWalletValue => 'On-chain value';

  @override
  String get portfolioSuppliedValue => 'Supplied value';

  @override
  String get portfolioBorrowedValue => 'Borrowed / debt';

  @override
  String get portfolioGrossValue => 'Gross value';

  @override
  String get portfolioHealthFactor => 'Health Factor';

  @override
  String get portfolioNoBorrowRisk => 'No borrow risk';

  @override
  String get portfolioHealthFactorUnavailable => 'Health Factor unavailable';

  @override
  String get portfolioAllocation => 'Allocation';

  @override
  String get portfolioAllocationAssets => 'Assets';

  @override
  String get portfolioAllocationDebts => 'Debts';

  @override
  String get portfolioAllocationProtocols => 'Protocols';

  @override
  String get portfolioAllocationNetworks => 'Networks';

  @override
  String get portfolioNoAllocationData => 'No allocation data';

  @override
  String get portfolioNoDebtPositions => 'No debt positions';

  @override
  String get portfolioNoProtocolAllocation => 'No protocol allocation';

  @override
  String get portfolioNoNetworkAllocation => 'No network allocation';

  @override
  String get portfolioAllocationOther => 'Other';

  @override
  String portfolioHealthFactorUpdatedAt(String date) {
    return 'HF updated: $date';
  }

  @override
  String get portfolioStaleData => 'Stale data';

  @override
  String get portfolioSafe => 'Safe';

  @override
  String get portfolioWatch => 'Watch';

  @override
  String get portfolioWarning => 'Warning';

  @override
  String get portfolioAtRisk => 'At risk';

  @override
  String get portfolioLiquidationRisk => 'Liquidation risk';

  @override
  String get portfolioUnknown => 'Unknown';

  @override
  String get portfolioOverviewScopeWalletFilter =>
      'Totals reflect the selected address across all protocols.';

  @override
  String get portfolioOverviewScopeProtocolWallet =>
      'Totals reflect the selected address. Protocol-specific address totals are shown in the DeFi groups below.';

  @override
  String get portfolioWalletHoldings => 'On-chain holdings';

  @override
  String get portfolioNoWalletHoldings => 'No on-chain holdings';

  @override
  String get portfolioDefiPositions => 'DeFi Positions';

  @override
  String get portfolioProtocolCategoryLending => 'Lending';

  @override
  String get portfolioSupplied => 'Supplied';

  @override
  String get portfolioBorrowed => 'Borrowed';

  @override
  String get portfolioDebt => 'Debt';

  @override
  String get portfolioLiability => 'Liability — reflected in net value';

  @override
  String get portfolioNoDefiPositions => 'No DeFi positions yet';

  @override
  String get portfolioNoSuppliedPositions => 'No supplied positions';

  @override
  String get portfolioNoBorrowedPositions => 'No borrowed positions';

  @override
  String get portfolioVariableDebt => 'Variable debt';

  @override
  String get portfolioStableDebt => 'Stable debt';

  @override
  String get portfolioRiskDetails => 'Risk Details';

  @override
  String get portfolioThreshold => 'Threshold';

  @override
  String get portfolioValueUnavailable => 'Value unavailable';

  @override
  String get portfolioWallets => 'Public addresses';

  @override
  String get portfolioAssets => 'Assets';

  @override
  String get portfolioNetworks => 'Networks';

  @override
  String get portfolioLastUpdated => 'Last updated';

  @override
  String get portfolioPriceUnavailable => 'Price unavailable';

  @override
  String get portfolioPriceStale => 'Price stale';

  @override
  String get portfolioPriceStatusUnknown => 'Unknown price status';

  @override
  String get portfolioNoAssets => 'No portfolio assets yet';

  @override
  String get portfolioEmptyHint =>
      'Add a public address in Profile, then refresh Portfolio.';

  @override
  String get portfolioLoadFailed => 'Failed to load portfolio';

  @override
  String get portfolioRetry => 'Retry';

  @override
  String get portfolioPullToRefresh => 'Pull to refresh';

  @override
  String get portfolioExportPdf => 'Export PDF';

  @override
  String get portfolioExportPdfShort => 'PDF';

  @override
  String get portfolioExportPdfPreparing => 'Preparing PDF...';

  @override
  String get portfolioExportPdfFailed => 'PDF export failed';

  @override
  String get portfolioExportPdfDownloaded => 'PDF report downloaded';

  @override
  String get portfolioNetworkTotal => 'Network total';

  @override
  String get portfolioTokenBalance => 'Balance';

  @override
  String get portfolioTokenPrice => 'Price';

  @override
  String get portfolioTokenValue => 'Value';

  @override
  String get portfolioCurrentPrice => 'Current Price';

  @override
  String get portfolioUsdValue => 'USD Value';

  @override
  String get portfolioWalletBreakdown => 'Address breakdown';

  @override
  String get portfolioSyncedAt => 'Synced at';

  @override
  String get portfolioBlockNumber => 'Block';

  @override
  String get portfolioAddress => 'Address';

  @override
  String get portfolioUpdatedNever => 'Never updated';

  @override
  String get portfolioAllProtocols => 'All protocols';

  @override
  String get portfolioAllWallets => 'All addresses';

  @override
  String get portfolioWallet => 'Address';

  @override
  String get portfolioProtocols => 'Protocols';

  @override
  String get portfolioTotal => 'Total';

  @override
  String get navPriceCalculator => 'Prices';

  @override
  String get navPortfolio => 'Portfolio';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get navHealthFactorCalculator => 'HF Calculator';

  @override
  String get alertsEmpty => 'No alerts yet';

  @override
  String get alertsLoading => 'Loading alerts…';

  @override
  String get alertsError => 'Could not load alerts. Try again later.';

  @override
  String get alertsNetworkError =>
      'Could not reach the server. Check your connection and try again.';

  @override
  String get alertsRefreshFailed =>
      'Could not refresh alerts. Pull down to try again.';

  @override
  String get alertsMarkReadFailed => 'Could not mark alert as read. Try again.';

  @override
  String get alertsMarkAllRead => 'Mark all as read';

  @override
  String get alertsMarkAllReadTooltip => 'Mark all alerts as read';

  @override
  String get alertsMarkAllReadFailed =>
      'Could not mark all alerts as read. Try again.';

  @override
  String get alertsMarkingAllRead => 'Marking as read…';

  @override
  String get alertsUnreadBadgeMax => '99+';

  @override
  String get alertsSeverityUnknown => 'Unknown';

  @override
  String get alertsScopeUnknown => 'Other';

  @override
  String get alertsUnsupportedType => 'Unsupported alert type';

  @override
  String get alertsMarkReadHint => 'Mark as read';

  @override
  String get alertsCopy => 'Copy';

  @override
  String get alertsCopiedToClipboard => 'Alert copied to clipboard';

  @override
  String get alertsCopyFailed => 'Could not copy alert';

  @override
  String get alertsCopiedTooltip => 'Copy alert summary';

  @override
  String get alertsRiskNewsDisclaimer =>
      'Rule-based risk signal, not financial advice';

  @override
  String get alertsRiskNewsScopeGlobal => '🌍 Global DeFi Risk';

  @override
  String get alertsRiskNewsScopeExposure => '⚠️ Your exposure detected';

  @override
  String get alertsRiskNewsScopeAdminOnly => '🛠 Internal/Admin';

  @override
  String get alertsRiskNewsSeverityCritical => 'Critical';

  @override
  String get alertsRiskNewsSeverityHigh => 'High';

  @override
  String get alertsRiskNewsSeverityMedium => 'Medium';

  @override
  String get alertsRiskNewsSeverityLow => 'Low';

  @override
  String get alertsRiskNewsSeverityWarning => 'Warning';

  @override
  String get alertsRiskNewsSeverityInfo => 'Info';

  @override
  String get alertsRiskNewsSource => 'Source';

  @override
  String get alertsRiskNewsSourceUnavailable => 'Source link unavailable';

  @override
  String get alertsRiskNewsSourceOpenFailed => 'Could not open source link';

  @override
  String get alertsRiskNewsGlobalReason => 'Reason';

  @override
  String get alertsRiskNewsMatchedAsset => 'Matched asset';

  @override
  String get alertsRiskNewsMatchedProtocol => 'Matched protocol';

  @override
  String get alertsRiskNewsMatchedChain => 'Matched chain';

  @override
  String alertsRiskNewsMatchConfidence(String value) {
    return 'Match confidence: $value';
  }

  @override
  String get alertsRiskNewsAffectedAssets => 'Affected assets';

  @override
  String get alertsRiskNewsAffectedProtocols => 'Affected protocols';

  @override
  String get alertsRiskNewsAffectedChains => 'Affected chains';

  @override
  String get alertsHfAlertTypeBreach => 'HF breach';

  @override
  String get alertsHfAlertTypeRecovery => 'HF recovery';

  @override
  String get alertsHfWallet => 'Address';

  @override
  String get alertsHfProtocol => 'Protocol';

  @override
  String get alertsHfNetwork => 'Network';

  @override
  String get alertsHfThreshold => 'Threshold';

  @override
  String get alertsHfThresholdLabel => '🎯 Alert threshold';

  @override
  String get alertsHfLiquidationHeadline => 'Liquidation';

  @override
  String get alertsHfLiquidationExplanation =>
      'Critical situation: your position may be liquidated';

  @override
  String get alertsHfBelowAlertThreshold =>
      'Health Factor below your alert threshold';

  @override
  String get alertsHfRecoveredAboveAlertThreshold =>
      'Health Factor recovered above your alert threshold';

  @override
  String get alertsHfCriticalHeadline => 'Health Factor critical';

  @override
  String get alertsHfRecoveryHeadline => 'Health Factor recovered';

  @override
  String get alertsHfPreviousHf => 'Previous HF';

  @override
  String get alertsHfCurrentHf => 'Current HF';

  @override
  String get alertsHfNetworkProtocol => 'Network · Protocol';

  @override
  String get alertsHfMovementChanged => 'Health Factor changed';

  @override
  String get alertsHfMovementImproved => 'Health Factor improved';

  @override
  String get alertsHfMovementDecreased => 'Health Factor decreased';

  @override
  String get alertsHfMovementUnchanged => 'Health Factor unchanged';

  @override
  String get hfCalcTitle => 'Health Factor Calculator';

  @override
  String get hfCalcSubtitle =>
      'Estimate your DeFi lending health factor using live market data.';

  @override
  String get hfCalcProtocol => 'Protocol';

  @override
  String get hfCalcSelectProtocol => 'Select protocol';

  @override
  String get hfCalcNetwork => 'Network';

  @override
  String get hfCalcSelectNetwork => 'Select network';

  @override
  String get hfCalcSupplySection => 'Supply / Collateral';

  @override
  String get hfCalcBorrowSection => 'Borrow';

  @override
  String get hfCalcAddSupply => 'Add supply';

  @override
  String get hfCalcAddBorrow => 'Add borrow';

  @override
  String get hfCalcAsset => 'Asset';

  @override
  String get hfCalcSelectAsset => 'Select asset';

  @override
  String get hfCalcAmount => 'Amount';

  @override
  String get hfCalcUseAsCollateral => 'Use as collateral';

  @override
  String get hfCalcCalculate => 'Calculate';

  @override
  String get hfCalcCalculating => 'Calculating…';

  @override
  String get hfCalcResult => 'Result';

  @override
  String get hfCalcHealthFactor => 'Health Factor';

  @override
  String get hfCalcRiskLevel => 'Risk level';

  @override
  String get hfCalcCollateralUsd => 'Collateral (USD)';

  @override
  String get hfCalcCollateralWeightedUsd => 'Weighted collateral (USD)';

  @override
  String get hfCalcBorrowUsd => 'Borrow (USD)';

  @override
  String get hfCalcWarnings => 'Warnings';

  @override
  String get hfCalcBreakdown => 'Position breakdown';

  @override
  String get hfCalcNoResultTitle => 'No result yet';

  @override
  String get hfCalcNoResultSubtitle =>
      'Enter supply and/or borrow positions, then calculate.';

  @override
  String get hfCalcLoading => 'Loading calculator…';

  @override
  String get hfCalcErrorTitle => 'Could not load calculator';

  @override
  String get hfCalcRetry => 'Retry';

  @override
  String get hfCalcUnauthenticatedTitle => 'Session expired';

  @override
  String get hfCalcUnauthenticatedMessage =>
      'Account access is required to calculate your health factor.';

  @override
  String get hfCalcNoMarkets =>
      'No market reserves available for this network.';

  @override
  String get hfCalcRemoveRow => 'Remove row';

  @override
  String get hfCalcNoProtocolsTitle => 'No protocols available';

  @override
  String get hfCalcNoProtocolsSubtitle =>
      'Health factor protocols could not be loaded.';

  @override
  String get hfCalcNoNetworksTitle => 'No networks available';

  @override
  String get hfCalcNoNetworksSubtitle =>
      'Try another protocol or check back later.';

  @override
  String get hfCalcRiskNoDebt => 'No debt';

  @override
  String get hfCalcRiskSafer => 'Safer';

  @override
  String get hfCalcRiskModerate => 'Moderate';

  @override
  String get hfCalcRiskWarning => 'Warning';

  @override
  String get hfCalcRiskHigh => 'High risk';

  @override
  String get hfCalcRiskCritical => 'Critical';

  @override
  String get hfCalcRiskLiquidation => 'Liquidation risk';

  @override
  String get hfCalcRiskUnknown => 'Unknown';

  @override
  String get hfCalcCurrentPrice => 'Current price';

  @override
  String get hfCalcMarketPrice => 'Market price';

  @override
  String get hfCalcUsedPrice => 'Used price';

  @override
  String get hfCalcCustomPrice => 'Custom price (USD)';

  @override
  String get hfCalcUseMarketPrice => 'Use market price';

  @override
  String get hfCalcSimulationOnly => 'Used for simulation only';

  @override
  String get hfCalcPriceUnavailable => 'Price unavailable';

  @override
  String get hfCalcCustomPriceUsed => 'Custom price used for simulation';

  @override
  String get hfCalcCustomPriceDiffers =>
      'Custom price differs significantly from market price';

  @override
  String get hfCalcPositionValue => 'Value';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get menuProfile => 'Profile';

  @override
  String get logIn => 'Account access';

  @override
  String get logOut => 'Log out';

  @override
  String get appUpdateAvailable =>
      'CryPrice was updated. Reload to continue safely.';

  @override
  String get appUpdateReload => 'Reload app';

  @override
  String get appUpdateManualInstructions =>
      'CryPrice could not refresh automatically. Close other tabs for this site, then reload the page or clear site data for app.cryprice.dev.';

  @override
  String get authStaleRecoveryMessage =>
      'CryPrice auth flow was updated. Reload the app and try again.';

  @override
  String get authStaleRecoveryReload => 'Reload app';

  @override
  String get googleAuthRedirectFailed =>
      'Google account access was cancelled or failed. Please try again.';

  @override
  String get appCacheReset => 'Reset app cache';

  @override
  String get appCacheResetConfirmTitle => 'Reset app cache?';

  @override
  String get appCacheResetConfirmMessage =>
      'This will clear local app cache and reload CryPrice. You may need to access your account again.';

  @override
  String get appCacheResetConfirmAction => 'Reset and reload';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get localeEn => 'EN';

  @override
  String get localeRu => 'RU';

  @override
  String get editPriceInput => 'Change';

  @override
  String priceInputSummary(String coin1, String coin2, String count) {
    return '$coin1 / $coin2 · $count';
  }
}

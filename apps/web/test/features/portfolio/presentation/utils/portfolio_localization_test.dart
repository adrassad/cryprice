import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('portfolio localization keys', () {
    final requiredGetters = <String, String Function(AppLocalizations)>{
      'portfolioAllProtocols': (loc) => loc.portfolioAllProtocols,
      'portfolioAllWallets': (loc) => loc.portfolioAllWallets,
      'portfolioProtocols': (loc) => loc.portfolioProtocols,
      'portfolioWallet': (loc) => loc.portfolioWallet,
      'portfolioWalletHoldings': (loc) => loc.portfolioWalletHoldings,
      'portfolioDefiPositions': (loc) => loc.portfolioDefiPositions,
      'portfolioSupplied': (loc) => loc.portfolioSupplied,
      'portfolioBorrowed': (loc) => loc.portfolioBorrowed,
      'portfolioDebt': (loc) => loc.portfolioDebt,
      'portfolioLiability': (loc) => loc.portfolioLiability,
      'portfolioTokenBalance': (loc) => loc.portfolioTokenBalance,
      'portfolioCurrentPrice': (loc) => loc.portfolioCurrentPrice,
      'portfolioUsdValue': (loc) => loc.portfolioUsdValue,
      'portfolioPriceUnavailable': (loc) => loc.portfolioPriceUnavailable,
      'portfolioValueUnavailable': (loc) => loc.portfolioValueUnavailable,
      'portfolioNetValue': (loc) => loc.portfolioNetValue,
      'portfolioGrossValue': (loc) => loc.portfolioGrossValue,
      'portfolioWalletValue': (loc) => loc.portfolioWalletValue,
      'portfolioSuppliedValue': (loc) => loc.portfolioSuppliedValue,
      'portfolioBorrowedValue': (loc) => loc.portfolioBorrowedValue,
      'portfolioHealthFactor': (loc) => loc.portfolioHealthFactor,
      'portfolioNoBorrowRisk': (loc) => loc.portfolioNoBorrowRisk,
      'portfolioHealthFactorUnavailable': (loc) => loc.portfolioHealthFactorUnavailable,
      'portfolioAllocationOther': (loc) => loc.portfolioAllocationOther,
      'portfolioHealthFactorUpdatedAt': (loc) =>
          loc.portfolioHealthFactorUpdatedAt('2026-05-19 13:30'),
      'portfolioStaleData': (loc) => loc.portfolioStaleData,
      'portfolioSafe': (loc) => loc.portfolioSafe,
      'portfolioWatch': (loc) => loc.portfolioWatch,
      'portfolioWarning': (loc) => loc.portfolioWarning,
      'portfolioAtRisk': (loc) => loc.portfolioAtRisk,
      'portfolioLiquidationRisk': (loc) => loc.portfolioLiquidationRisk,
      'portfolioUnknown': (loc) => loc.portfolioUnknown,
    };

    test('English strings are non-empty', () {
      final loc = lookupAppLocalizations(const Locale('en'));
      for (final entry in requiredGetters.entries) {
        expect(entry.value(loc).trim(), isNotEmpty, reason: entry.key);
      }
    });

    test('Russian strings are non-empty', () {
      final loc = lookupAppLocalizations(const Locale('ru'));
      for (final entry in requiredGetters.entries) {
        expect(entry.value(loc).trim(), isNotEmpty, reason: entry.key);
      }
    });

    test('Russian portfolio labels differ from English where expected', () {
      final en = lookupAppLocalizations(const Locale('en'));
      final ru = lookupAppLocalizations(const Locale('ru'));

      expect(ru.portfolioWalletHoldings, isNot(en.portfolioWalletHoldings));
      expect(ru.portfolioNetValue, isNot(en.portfolioNetValue));
      expect(ru.portfolioPriceUnavailable, isNot(en.portfolioPriceUnavailable));
    });
  });
}

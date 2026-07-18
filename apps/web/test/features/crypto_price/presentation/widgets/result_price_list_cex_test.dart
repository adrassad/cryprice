import 'package:cryprice_frontend/features/crypto_price/domain/entities/offchain_convert_result.dart';
import 'package:cryprice_frontend/features/crypto_price/presentation/widgets/cex_convert_card.dart';
import 'package:cryprice_frontend/features/crypto_price/presentation/widgets/result_price_list.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

OffchainConvertResult _convert({
  OffchainVenueConvert? binance,
  OffchainVenueConvert? bybit,
}) {
  return OffchainConvertResult(
    coin1: 'BTC',
    coin2: 'AVAX',
    count: 0.12,
    binance: binance,
    bybit: bybit,
  );
}

void main() {
  testWidgets('renders two CexConvertCard widgets when convert has venues', (
    tester,
  ) async {
    late AppLocalizations loc;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            loc = AppLocalizations.of(context)!;
            return ResultPriceList(
              rows: const [],
              l10n: loc,
              countMultiplier: 0.12,
              userTicker1: 'BTC',
              userTicker2: 'AVAX',
              localizeError: (_) => 'err',
              offchainConvert: _convert(
                binance: const OffchainVenueConvert(sum: 100, collected: null),
                bybit: const OffchainVenueConvert(sum: 101, collected: null),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CexConvertCard), findsNWidgets(2));
    expect(find.text(loc.resultsSectionCexTitle), findsOneWidget);
  });

  testWidgets('synthetic fallback shows CEX section with error cards', (
    tester,
  ) async {
    late AppLocalizations loc;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            loc = AppLocalizations.of(context)!;
            return ResultPriceList(
              rows: const [],
              l10n: loc,
              countMultiplier: 0.12,
              userTicker1: 'BTC',
              userTicker2: 'AVAX',
              localizeError: (_) => 'missing',
              offchainConvert: _convert(),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CexConvertCard), findsNWidgets(2));
    expect(find.textContaining('BINANCE'), findsOneWidget);
    expect(find.textContaining('BYBIT'), findsOneWidget);
    expect(find.textContaining('missing'), findsNWidgets(2));
  });

  testWidgets('shows CEX and DEX sections together', (tester) async {
    late AppLocalizations loc;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            loc = AppLocalizations.of(context)!;
            return ResultPriceList(
              rows: const [],
              l10n: loc,
              countMultiplier: 1,
              userTicker1: 'BTC',
              userTicker2: 'AVAX',
              localizeError: (_) => 'err',
              offchainConvert: _convert(
                binance: const OffchainVenueConvert(sum: 50, collected: null),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(loc.resultsSectionCexTitle), findsOneWidget);
    expect(find.text(loc.resultsSectionDexTitle), findsOneWidget);
  });
}

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

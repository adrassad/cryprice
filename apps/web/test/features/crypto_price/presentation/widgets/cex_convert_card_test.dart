import 'package:cryprice_frontend/features/crypto_price/domain/entities/offchain_convert_result.dart';
import 'package:cryprice_frontend/features/crypto_price/presentation/widgets/cex_convert_card.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows sum and coin2 label when venue result present', (
    tester,
  ) async {
    late AppLocalizations loc;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            loc = AppLocalizations.of(context)!;
            return CexConvertCard(
              l10n: loc,
              venue: 'binance',
              coin1: 'BTC',
              coin2: 'AVAX',
              count: 0.12,
              venueResult: const OffchainVenueConvert(
                sum: 1108.85,
                collected: null,
              ),
              localizeError: (_) => 'failed',
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AVAX'), findsOneWidget);
    expect(find.textContaining('1108'), findsOneWidget);
    expect(find.text(loc.resultsCexConvertHint('0.12', 'BTC', 'AVAX')), findsOneWidget);
  });

  testWidgets('shows error line when venue result is null', (tester) async {
    late AppLocalizations loc;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            loc = AppLocalizations.of(context)!;
            return CexConvertCard(
              l10n: loc,
              venue: 'bybit',
              coin1: 'BTC',
              coin2: 'AVAX',
              count: 1,
              venueResult: null,
              localizeError: (_) => 'no data',
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('BYBIT'), findsOneWidget);
    expect(find.textContaining('no data'), findsOneWidget);
  });

  testWidgets('copy button tap does not throw', (tester) async {
    late AppLocalizations loc;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            loc = AppLocalizations.of(context)!;
            return CexConvertCard(
              l10n: loc,
              venue: 'binance',
              coin1: 'BTC',
              coin2: 'USDT',
              count: 1,
              venueResult: const OffchainVenueConvert(sum: 100, collected: null),
              localizeError: (_) => 'failed',
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.copy_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.copy_outlined));
    await tester.pump();
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
    home: Scaffold(body: child),
  );
}

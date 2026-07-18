import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_warning.dart';
import 'package:cryprice_frontend/features/health_factor/presentation/widgets/health_factor_warning_list.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders warning messages', (tester) async {
    await tester.pumpWidget(
      _wrap(
        HealthFactorWarningList(
          title: 'Warnings',
          warnings: const [
            HealthFactorWarning(code: 'LOW_HF', message: 'Health factor is low'),
            HealthFactorWarning(code: 'STALE', message: 'Prices may be stale'),
          ],
        ),
      ),
    );

    expect(find.text('Warnings'), findsOneWidget);
    expect(find.text('Health factor is low'), findsOneWidget);
    expect(find.text('Prices may be stale'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsNWidgets(2));
  });

  testWidgets('CUSTOM_PRICE_USED warning renders localized text', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const HealthFactorWarningList(
          title: 'Warnings',
          warnings: [
            HealthFactorWarning(
              code: 'CUSTOM_PRICE_USED',
              message: 'ignored backend message',
            ),
          ],
        ),
      ),
    );

    expect(find.text('Custom price used for simulation'), findsOneWidget);
    expect(find.text('ignored backend message'), findsNothing);
  });

  testWidgets('CUSTOM_PRICE_DIFFERS_FROM_MARKET warning renders localized text', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const HealthFactorWarningList(
          title: 'Warnings',
          warnings: [
            HealthFactorWarning(
              code: 'CUSTOM_PRICE_DIFFERS_FROM_MARKET',
              message: 'ignored',
            ),
          ],
        ),
      ),
    );

    expect(
      find.text('Custom price differs significantly from market price'),
      findsOneWidget,
    );
  });

  testWidgets('hides when warnings empty', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const HealthFactorWarningList(
          title: 'Warnings',
          warnings: <HealthFactorWarning>[],
        ),
      ),
    );

    expect(find.text('Warnings'), findsNothing);
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

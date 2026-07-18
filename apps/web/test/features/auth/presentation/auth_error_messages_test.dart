import 'package:cryprice_frontend/features/auth/presentation/auth_error_messages.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('maps redirect failure code to localized messages', (tester) async {
    late AppLocalizations enLoc;
    late AppLocalizations ruLoc;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (BuildContext context) {
            enLoc = AppLocalizations.of(context)!;
            return const SizedBox();
          },
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ru'),
        home: Builder(
          builder: (BuildContext context) {
            ruLoc = AppLocalizations.of(context)!;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(
      resolveAuthErrorMessage(enLoc, kGoogleAuthRedirectFailedErrorCode),
      'Google account access was cancelled or failed. Please try again.',
    );
    expect(
      resolveAuthErrorMessage(ruLoc, kGoogleAuthRedirectFailedErrorCode),
      'Доступ к аккаунту через Google был отменён или завершился ошибкой. Попробуйте ещё раз.',
    );
    expect(
      resolveAuthErrorMessage(enLoc, 'network'),
      'network',
    );
  });
}

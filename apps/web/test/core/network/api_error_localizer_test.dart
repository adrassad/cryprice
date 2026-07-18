import 'package:cryprice_frontend/core/network/api_error_localizer.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('localizeApiError maps RATE_LIMITED code to EN message', () {
    final loc = lookupAppLocalizations(const Locale('en'));
    expect(
      localizeApiError(loc, code: 'RATE_LIMITED'),
      'Too many requests. Please wait a moment and try again.',
    );
  });

  test('localizeApiError maps 429 status to RU message', () {
    final loc = lookupAppLocalizations(const Locale('ru'));
    expect(
      localizeApiError(loc, statusCode: 429),
      'Слишком много запросов. Подождите немного и попробуйте снова.',
    );
  });
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Курс Криптовалют';

  @override
  String get switchLanguage => 'Переключить на английский';

  @override
  String get switchTheme => 'Переключить стиль';

  @override
  String get getPrice => 'Узнать курс';

  @override
  String get count => 'Количество';

  @override
  String get coin1 => 'Монета 1';

  @override
  String get coin2 => 'Монета 2';

  @override
  String get enterTicker => 'Введите тикеры и количество.';

  @override
  String get error_fetch_failed => 'Не удалось получить цену';

  @override
  String get error_no_internet => 'Нет подключения к интернету';

  @override
  String get error_unknown => 'Произошла неизвестная ошибка';

  @override
  String get resultsSectionCexTitle => 'CEX-цены';

  @override
  String get resultsSectionCexSubtitle =>
      'Биржи, индексы, off-chain API — один GET, тикер — последний сегмент пути';

  @override
  String get resultsSectionDexTitle => 'DEX-цены';

  @override
  String get resultsSectionDexSubtitle =>
      'On-chain: один GET на тикер; в теле — все сети (ключ = сеть, null = нет цены)';

  @override
  String get resultsSectionDexEmpty =>
      'Нет on-chain котировок для этого тикера.';

  @override
  String get priceTypeCex => 'CEX';

  @override
  String get priceTypeAggregated => 'Индекс / API';

  @override
  String get priceTypeOffchain => 'Off-chain';

  @override
  String get priceTypeOnchain => 'On-chain';

  @override
  String get unknownNetwork => 'Неизвестная сеть';

  @override
  String get labelNetwork => 'Сеть';

  @override
  String get labelSymbol => 'Символ';

  @override
  String get labelCollected => 'Собрано';

  @override
  String get labelPair => 'Пара';

  @override
  String get labelUpdated => 'Обновлено';

  @override
  String get sourceCryprice => 'CRYPRICE';

  @override
  String get typeDex => 'DEX';

  @override
  String get labelTokenAddress => 'Контракт';

  @override
  String get statusFallback => 'Резерв';

  @override
  String get statusStale => 'Устарело';

  @override
  String get emDash => '—';

  @override
  String resultsContextNetwork(String name) {
    return 'Сеть: $name';
  }

  @override
  String resultsContextAddress(String addr) {
    return 'Адр.: $addr';
  }

  @override
  String resultsSymbolLine(String value) {
    return 'Символ: $value';
  }

  @override
  String resultsNetworkLine(String value) {
    return 'Сеть: $value';
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
  String get copiedToClipboard => 'Скопировано в буфер обмена';

  @override
  String get labelPrice => 'Цена';

  @override
  String get authScreenTitle => 'Вход';

  @override
  String get authScreenSubtitle =>
      'Войдите, чтобы продолжить. Сеанс хранится на этом устройстве.';

  @override
  String get signIn => 'Войти';

  @override
  String get signOut => 'Выйти';

  @override
  String get signInWithGoogle => 'Продолжить с Google';

  @override
  String get googleSignInWebTryAgain => 'Повторить';
}

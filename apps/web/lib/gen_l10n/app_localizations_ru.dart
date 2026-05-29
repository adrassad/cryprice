// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'CryPrice';

  @override
  String get switchLanguage => 'Переключить на английский';

  @override
  String get switchTheme => 'Переключить стиль';

  @override
  String get appSettingsMenu => 'Настройки';

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
  String get profileTitle => 'Профиль';

  @override
  String get loginRequired => 'Требуется авторизация';

  @override
  String get profileLoadFailed => 'Не удалось загрузить профиль';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get language => 'Язык';

  @override
  String get thresholdHf => 'Threshold HF';

  @override
  String get username => 'Username';

  @override
  String get firstName => 'Имя';

  @override
  String get lastName => 'Фамилия';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get walletsTitle => 'Кошельки';

  @override
  String get walletsEmpty => 'Кошельки пока не добавлены';

  @override
  String get addWallet => 'Добавить кошелек';

  @override
  String get walletAddress => 'Адрес';

  @override
  String get walletLabel => 'Label';

  @override
  String get editWalletLabel => 'Изменить label';

  @override
  String get deleteWallet => 'Удалить кошелек';

  @override
  String get deleteWalletConfirm => 'Вы действительно хотите удалить кошелек?';

  @override
  String get delete => 'Удалить';

  @override
  String get walletAddressRequired => 'Введите адрес кошелька';

  @override
  String get walletAddressStartWith0x => 'Адрес должен начинаться с 0x';

  @override
  String get walletAddressLengthHint =>
      'Ожидаемая длина EVM адреса: 42 символа';

  @override
  String get notSpecified => 'Не указано';

  @override
  String get telegramId => 'Telegram ID';

  @override
  String get profileTelegramTitle => 'Telegram';

  @override
  String get profileTelegramLinked => 'Telegram привязан';

  @override
  String get profileTelegramLinkPrompt =>
      'Привяжите Telegram, чтобы получать уведомления.';

  @override
  String get profileTelegramLinkButton => 'Привязать Telegram';

  @override
  String get profileHfAlertsTitle => 'Оповещения Health Factor';

  @override
  String get profileHfAlertsDescription =>
      'Уведомлять, когда мой Health Factor в Aave опускается ниже этого порога.';

  @override
  String get profileHfAlertsEnabled => 'Включено';

  @override
  String get profileHfAlertsHelper =>
      'Оповещение срабатывает при пересечении порога, а не пока HF просто остаётся ниже него.';

  @override
  String get profileHfAlertsTelegramWarning =>
      'Telegram не привязан. Настройки сохранятся в приложении, но доставка в Telegram требует привязки Telegram.';

  @override
  String get profileHfAlertsLegacySyncFailed =>
      'Правило оповещения сохранено, но синхронизация legacy-порога профиля не удалась.';

  @override
  String get profileHfAlertsSaveSuccess => 'Настройки оповещения сохранены';

  @override
  String profileHfThresholdRangeError(String min, String max) {
    return 'Порог Health Factor должен быть от $min до $max';
  }

  @override
  String get email => 'Email';

  @override
  String get emailVerified => 'Email подтвержден';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get createdAt => 'Создан';

  @override
  String get portfolioTitle => 'Портфель';

  @override
  String get portfolioTotalValue => 'Общая стоимость';

  @override
  String get portfolioNetValue => 'Чистая стоимость';

  @override
  String get portfolioWalletValue => 'Стоимость кошельков';

  @override
  String get portfolioSuppliedValue => 'Вложено в DeFi';

  @override
  String get portfolioBorrowedValue => 'Заем / долг';

  @override
  String get portfolioGrossValue => 'Валовая стоимость';

  @override
  String get portfolioHealthFactor => 'Health Factor';

  @override
  String get portfolioNoBorrowRisk => 'Нет риска займа';

  @override
  String get portfolioHealthFactorUnavailable => 'Health Factor недоступен';

  @override
  String get portfolioAllocation => 'Распределение';

  @override
  String get portfolioAllocationAssets => 'Активы';

  @override
  String get portfolioAllocationDebts => 'Долги';

  @override
  String get portfolioAllocationProtocols => 'Протоколы';

  @override
  String get portfolioAllocationNetworks => 'Сети';

  @override
  String get portfolioNoAllocationData => 'Нет данных для диаграммы';

  @override
  String get portfolioNoDebtPositions => 'Нет долговых позиций';

  @override
  String get portfolioNoProtocolAllocation => 'Нет данных по протоколам';

  @override
  String get portfolioNoNetworkAllocation => 'Нет данных по сетям';

  @override
  String get portfolioAllocationOther => 'Другое';

  @override
  String portfolioHealthFactorUpdatedAt(String date) {
    return 'HF обновлён: $date';
  }

  @override
  String get portfolioStaleData => 'Устаревшие данные';

  @override
  String get portfolioSafe => 'Безопасно';

  @override
  String get portfolioWatch => 'Наблюдение';

  @override
  String get portfolioWarning => 'Предупреждение';

  @override
  String get portfolioAtRisk => 'В зоне риска';

  @override
  String get portfolioLiquidationRisk => 'Риск ликвидации';

  @override
  String get portfolioUnknown => 'Неизвестно';

  @override
  String get portfolioOverviewScopeWalletFilter =>
      'Итоги отражают выбранный кошелек по всем протоколам.';

  @override
  String get portfolioOverviewScopeProtocolWallet =>
      'Итоги отражают выбранный кошелек. Детали по протоколу и сети — в группах DeFi ниже.';

  @override
  String get portfolioWalletHoldings => 'Активы кошельков';

  @override
  String get portfolioNoWalletHoldings => 'Нет активов кошельков';

  @override
  String get portfolioDefiPositions => 'DeFi-позиции';

  @override
  String get portfolioProtocolCategoryLending => 'Кредитование';

  @override
  String get portfolioSupplied => 'Вложено';

  @override
  String get portfolioBorrowed => 'Заем';

  @override
  String get portfolioDebt => 'Долг';

  @override
  String get portfolioLiability => 'Обязательство — учтено в чистой стоимости';

  @override
  String get portfolioNoDefiPositions => 'Пока нет DeFi-позиций';

  @override
  String get portfolioNoSuppliedPositions => 'Нет вложенных позиций';

  @override
  String get portfolioNoBorrowedPositions => 'Нет заемных позиций';

  @override
  String get portfolioVariableDebt => 'Переменный долг';

  @override
  String get portfolioStableDebt => 'Стабильный долг';

  @override
  String get portfolioRiskDetails => 'Детали риска';

  @override
  String get portfolioThreshold => 'Порог';

  @override
  String get portfolioValueUnavailable => 'Стоимость недоступна';

  @override
  String get portfolioWallets => 'Кошельки';

  @override
  String get portfolioAssets => 'Активы';

  @override
  String get portfolioNetworks => 'Сети';

  @override
  String get portfolioLastUpdated => 'Обновлено';

  @override
  String get portfolioPriceUnavailable => 'Цена недоступна';

  @override
  String get portfolioPriceStale => 'Цена устарела';

  @override
  String get portfolioPriceStatusUnknown => 'Неизвестный статус цены';

  @override
  String get portfolioNoAssets => 'В портфеле пока нет активов';

  @override
  String get portfolioEmptyHint =>
      'Добавьте или синхронизируйте кошелек в профиле, затем обновите портфель.';

  @override
  String get portfolioLoadFailed => 'Не удалось загрузить портфель';

  @override
  String get portfolioRetry => 'Повторить';

  @override
  String get portfolioPullToRefresh => 'Потяните для обновления';

  @override
  String get portfolioExportPdf => 'Экспорт PDF';

  @override
  String get portfolioExportPdfShort => 'PDF';

  @override
  String get portfolioExportPdfPreparing => 'Готовим PDF...';

  @override
  String get portfolioExportPdfFailed => 'Не удалось выгрузить PDF';

  @override
  String get portfolioExportPdfDownloaded => 'PDF-отчёт загружен';

  @override
  String get portfolioNetworkTotal => 'Итого по сети';

  @override
  String get portfolioTokenBalance => 'Баланс';

  @override
  String get portfolioTokenPrice => 'Цена';

  @override
  String get portfolioTokenValue => 'Стоимость';

  @override
  String get portfolioCurrentPrice => 'Текущая цена';

  @override
  String get portfolioUsdValue => 'Стоимость в USD';

  @override
  String get portfolioWalletBreakdown => 'Детализация по кошелькам';

  @override
  String get portfolioSyncedAt => 'Синхронизировано';

  @override
  String get portfolioBlockNumber => 'Блок';

  @override
  String get portfolioAddress => 'Адрес';

  @override
  String get portfolioUpdatedNever => 'Нет данных об обновлении';

  @override
  String get portfolioAllProtocols => 'Все протоколы';

  @override
  String get portfolioAllWallets => 'Все кошельки';

  @override
  String get portfolioWallet => 'Кошелек';

  @override
  String get portfolioProtocols => 'Протоколы';

  @override
  String get portfolioTotal => 'Итого';

  @override
  String get navPriceCalculator => 'Цены';

  @override
  String get navPortfolio => 'Портфель';

  @override
  String get navAlerts => 'Оповещения';

  @override
  String get navHealthFactorCalculator => 'Калькулятор HF';

  @override
  String get alertsEmpty => 'Оповещений пока нет';

  @override
  String get alertsLoading => 'Загрузка оповещений…';

  @override
  String get alertsError =>
      'Не удалось загрузить оповещения. Попробуйте позже.';

  @override
  String get alertsNetworkError =>
      'Не удалось связаться с сервером. Проверьте подключение и повторите попытку.';

  @override
  String get alertsRefreshFailed =>
      'Не удалось обновить оповещения. Потяните вниз, чтобы повторить.';

  @override
  String get alertsMarkReadFailed =>
      'Не удалось отметить оповещение прочитанным. Попробуйте снова.';

  @override
  String get alertsUnreadBadgeMax => '99+';

  @override
  String get alertsSeverityUnknown => 'Неизвестно';

  @override
  String get alertsScopeUnknown => 'Другое';

  @override
  String get alertsUnsupportedType => 'Неподдерживаемый тип оповещения';

  @override
  String get alertsMarkReadHint => 'Отметить прочитанным';

  @override
  String get alertsCopy => 'Копировать';

  @override
  String get alertsCopiedToClipboard => 'Оповещение скопировано в буфер обмена';

  @override
  String get alertsCopyFailed => 'Не удалось скопировать оповещение';

  @override
  String get alertsCopiedTooltip => 'Копировать сводку оповещения';

  @override
  String get alertsRiskNewsDisclaimer =>
      'Сигнал на основе правил, не финансовая рекомендация';

  @override
  String get alertsRiskNewsScopeGlobal => '🌍 Глобальный DeFi-риск';

  @override
  String get alertsRiskNewsScopeExposure => '⚠️ Обнаружена ваша экспозиция';

  @override
  String get alertsRiskNewsScopeAdminOnly => '🛠 Внутреннее / админ';

  @override
  String get alertsRiskNewsSeverityCritical => 'Критический';

  @override
  String get alertsRiskNewsSeverityHigh => 'Высокий';

  @override
  String get alertsRiskNewsSeverityMedium => 'Средний';

  @override
  String get alertsRiskNewsSeverityLow => 'Низкий';

  @override
  String get alertsRiskNewsSeverityWarning => 'Предупреждение';

  @override
  String get alertsRiskNewsSeverityInfo => 'Инфо';

  @override
  String get alertsRiskNewsSource => 'Источник';

  @override
  String get alertsRiskNewsSourceUnavailable => 'Ссылка на источник недоступна';

  @override
  String get alertsRiskNewsSourceOpenFailed => 'Не удалось открыть ссылку';

  @override
  String get alertsRiskNewsGlobalReason => 'Причина';

  @override
  String get alertsRiskNewsMatchedAsset => 'Совпавший актив';

  @override
  String get alertsRiskNewsMatchedProtocol => 'Совпавший протокол';

  @override
  String get alertsRiskNewsMatchedChain => 'Совпавшая сеть';

  @override
  String alertsRiskNewsMatchConfidence(String value) {
    return 'Уверенность совпадения: $value';
  }

  @override
  String get alertsRiskNewsAffectedAssets => 'Затронутые активы';

  @override
  String get alertsRiskNewsAffectedProtocols => 'Затронутые протоколы';

  @override
  String get alertsRiskNewsAffectedChains => 'Затронутые сети';

  @override
  String get alertsHfAlertTypeBreach => 'Пробой HF';

  @override
  String get alertsHfAlertTypeRecovery => 'Восстановление HF';

  @override
  String get alertsHfWallet => 'Кошелёк';

  @override
  String get alertsHfProtocol => 'Протокол';

  @override
  String get alertsHfNetwork => 'Сеть';

  @override
  String get alertsHfThreshold => 'Порог';

  @override
  String get alertsHfThresholdLabel => '🎯 Порог оповещения';

  @override
  String get alertsHfLiquidationHeadline => 'Ликвидация';

  @override
  String get alertsHfLiquidationExplanation =>
      'Критическая ситуация: позиция может быть ликвидирована';

  @override
  String get alertsHfBelowAlertThreshold =>
      'Health Factor ниже вашего порога оповещения';

  @override
  String get alertsHfRecoveredAboveAlertThreshold =>
      'Health Factor восстановился выше вашего порога оповещения';

  @override
  String get alertsHfCriticalHeadline => 'Health Factor критический';

  @override
  String get alertsHfRecoveryHeadline => 'Health Factor восстановлен';

  @override
  String get alertsHfPreviousHf => 'Предыдущий HF';

  @override
  String get alertsHfCurrentHf => 'Текущий HF';

  @override
  String get alertsHfNetworkProtocol => 'Сеть · Протокол';

  @override
  String get alertsHfMovementChanged => 'Health Factor изменился';

  @override
  String get alertsHfMovementImproved => 'Health Factor улучшился';

  @override
  String get alertsHfMovementDecreased => 'Health Factor снизился';

  @override
  String get alertsHfMovementUnchanged => 'Health Factor без изменений';

  @override
  String get comingSoon => 'Скоро';

  @override
  String get menuProfile => 'Профиль';

  @override
  String get logIn => 'Войти';

  @override
  String get logOut => 'Выйти';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get localeEn => 'EN';

  @override
  String get localeRu => 'RU';

  @override
  String get editPriceInput => 'Изменить';

  @override
  String priceInputSummary(String coin1, String coin2, String count) {
    return '$coin1 / $coin2 · $count';
  }
}

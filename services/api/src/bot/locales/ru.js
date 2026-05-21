// src/locales/ru.js
export default {
  // Общие
  common: {
    yes: "Да",
    no: "Нет",
    notSpecified: "не указано",
  },
  main_menu: "🏠 Главное меню",
  welcome: "👋 Привет! Я ваш помощник.",
  error: "⚠️ Произошла ошибка. Попробуйте позже.",
  status: "Статус:",

  //threshold
  threshhold_enter:
    "🎚 Введите пороговое значение Health Factor.\n\nНапример: 1.20\nДля отмены отправьте /cancel",
  threshold_error: "Некорректное значение. Введите число, например: 1.20",
  threshold_updated: "✅ Ваше пороговое значение Health Factor обновлено:",
  action_cancel: "Действие отменено.",
  nothing_to_cancel: "Нечего отменять.",
  threshold_value: "Пороговое значение HealthFactor: ",

  //Профиль
  profile: {
    title: "👤 <b>Профиль</b>",
    notFound: "❌ Профиль не найден.",
    telegramId: "🆔 <b>Telegram ID:</b> <code>{telegramId}</code>",
    name: "🙍 <b>Имя:</b> {name}",
    username: "🔗 <b>Username:</b> {username}",
    settingsTitle: "⚙️ <b>Настройки</b>",
    threshold: "📉 <b>Порог Health Factor:</b> {value}",
  },

  start_linked_success: `✅ Бот уже активирован.

Вы будете получать уведомления CryPrice здесь.
Настройки можно изменить в профиле:
https://app.cryprice.dev`,

  start_not_linked: `👋 Добро пожаловать в CryPrice.

Чтобы активировать Telegram-бота, сначала войдите в свой аккаунт на сайте и подключите Telegram в настройках профиля:

https://app.cryprice.dev

Это нужно, чтобы бот был привязан к вашему основному аккаунту и не создавал дубликаты.`,

  start_link_success: `✅ Telegram успешно подключён к вашему аккаунту CryPrice.

Теперь вы сможете получать уведомления здесь.
Настройки можно изменить в профиле:
https://app.cryprice.dev`,

  start_link_failed: `❌ Не удалось подключить Telegram.

Возможно, ссылка устарела или уже была использована.
Пожалуйста, создайте новую ссылку в настройках профиля:
https://app.cryprice.dev`,

  //Команды телеги
  help_command: `ℹ️ Доступные команды:
  /start — начать
  /add_wallet — добавить кошелёк
  /set_threshold — установить порог Health Factor
  /help — помощь
  /status - статус пользователя
  /positions - позиции на aave
  /healthfactor - 🛡 Показать Health Factor на aave`,
  command_wallet_no_add:
    "⚠️ У вас ещё нет кошельков. Добавьте через ➕ Add Wallet.",
  command_wallet_select:
    "💼 Выберите кошелек для получения Health Factor на Aave:",
  command_show_positions: "💼 Выберите кошелек для просмотра позиций:",

  // Поддержка
  support_public_notice:
    "💬 Для поддержки войдите в приложение CryPrice после авторизации или используйте issue tracker публичного репозитория.",

  // Позиции и Aave
  no_active_positions: "ℹ️ Нет активных позиций в Aave.",
  positions_overview: "📊 Ваши текущие позиции:",

  no_user: "❌ Пользователь не найден",
  novalid_address:
    "❌ Невалидный адрес.\n\nОтправьте корректный адрес или /cancel",
  wallet_limit_reached:
    "⚠️ Достигнут лимит кошельков. Удалите существующий кошелёк, прежде чем добавлять новый.",

  //Кошельки
  wallets: {
    empty: "Список кошельков пуст.",
    no_wallet: "❌ Кошелек не найден",
    wallet_you_have:
      "⚠️ Этот кошелёк уже добавлен.\nОтправьте другой адрес или /cancel",
    wallet_buttom_add: "➕ Добавить кошелёк",
    wallet_buttom_del: "➖ Удалить кошелёк",
    wallet_deleted: "🗑 Кошелёк удалён",
    wallet_deleted_success: "✅ Кошелёк успешно удалён",
    wallet_select_delete: "💼 Выберите кошелек для удаления:",
    wallet_deleted_error: "❌ Ошибка",
    wallet_deleted_failed: "⚠️ Не удалось удалить кошелёк",
    wallet_send: `➕ Отправьте адрес EVM кошелька
      Пример:
      0x1234...abcd
      Для отмены: /cancel`,
    wallet_send_canceled: "❌ Добавление кошелька отменено",
    wallet_sending: `ℹ️ Сейчас идёт добавление кошелька.
      Отправьте адрес или /cancel`,
    wallet_added: "✅ Кошелёк успешно добавлен",
  },

  token_not_found: "🪙 Токен <b>{symbol}</b> не найден",
  // Healthfactor
  healthfactor_overview: "🛡 Ваш текущий Health Factor:",

  // Ошибки
  error_generic: "❌ Произошла ошибка. Попробуйте ещё раз.",

  requests_limit: "⛔ Слишком много запросов. Попробуйте позже.",
};

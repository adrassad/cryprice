// src/locales/ru.js
export default {
  // Общие
  common: {
    yes: "Да",
    no: "Нет",
    active: "✅ Активна",
    expired: "❌ Истекла",
    notSpecified: "не указано",
  },
  users: {
    listTitle: "Выберите пользователя:",
    pageInfo: "Страница {current} из {total}",
    prevButton: "⬅️ Назад",
    nextButton: "Вперед ➡️",
    backToList: "🔙 К списку",
    empty: "Список пользователей пуст.",
    error: "❌ Не удалось загрузить список пользователей.",
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
  threshold_value: "Пороговое значение HealthFactor: ",

  //Профиль
  profile: {
    title: "👤 <b>Профиль</b>",
    notFound: "❌ Профиль не найден.",
    telegramId: "🆔 <b>Telegram ID:</b> <code>{telegramId}</code>",
    name: "🙍 <b>Имя:</b> {name}",
    username: "🔗 <b>Username:</b> {username}",
    subscriptionTitle: "💳 <b>Подписка</b>",
    plan: "📦 <b>Тариф:</b> {plan}",
    validUntil: "📅 <b>Действует до:</b> {date}",
    status: "📍 <b>Статус:</b> {status}",
    settingsTitle: "⚙️ <b>Настройки</b>",
    threshold: "📉 <b>Порог Health Factor:</b> {value}",
    renewHint: "💡 <i>Чтобы продолжить мониторинг, продлите подписку.</i>",
    freePlan: "🆓 Free",
    proPlan: "⭐ Pro",
  },

  start_welcome: `👋 Добро пожаловать!

  🤖 <b>Aave Health Monitor</b>

  Я слежу за <b>Health Factor</b> твоих кошельков в AAVE (Arbitrum)
  и предупреждаю, если появляется риск ликвидации ⚠️

  ---

  🚀 <b>Начать просто:</b>

  1. Добавь кошелёк → /add_wallet
  2. Установи порог HF → /set_threshold
  3. Я буду мониторить и присылать уведомления 🔔

  ---

  📊 <b>Что я умею:</b>

  • Отслеживаю Health Factor
  • Уведомляю о риске ликвидации
  • Отслеживаю изменения цен (>5%)
  • Поддержка нескольких кошельков 💼

  ---

  💡 <b>Быстрый лайфхак:</b>

  Просто напиши: <code>ETH</code> <code>BTC</code> <code>AVAX</code>

  → и я покажу текущую цену 📈

  ---

  📌 /help — список команд
  📌 /profile — профиль и настройки
`,
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
  support_enter:
    "✍️ Напишите ваше сообщение в поддержку.\n\nДля отмены отправьте /cancel",
  support_canceled: "❌ Отправка сообщения отменена.",
  support_sent: "✅ Ваше сообщение отправлено в поддержку.",
  support_sent_title: "Новое обращение в поддержку",
  support_answer: "💬 Ответить",
  support_no_rules: "Недостаточно прав",
  support_enter_answer: "✍️ Введите ответ пользователю:",
  support_answer_support: "Ответ поддержки:",
  support_answered_user: "✅ Ответ отправлен пользователю.",
  support_answered_support: "✅ Ваше сообщение отправлено в поддержку.",
  support_public_notice:
    "ℹ️ В этой публичной сборке сообщения оператору не пересылаются.\nСм. README.md — как сообщить об ошибке или внести вклад.",
  message: "Сообщение:",
  // Позиции и Aave
  no_active_positions: "ℹ️ Нет активных позиций в Aave.",
  positions_overview: "📊 Ваши текущие позиции:",

  no_user: "❌ Пользователь не найден",
  wallet_limit_reached:
    "⚠️ Достигнут лимит кошельков. Удалите один или увеличьте MAX_WALLETS_PER_USER.",
  novalid_address:
    "❌ Невалидный адрес.\n\nОтправьте корректный адрес или /cancel",

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

  //support
  support_write_message: `✍️ Напишите ваше сообщение в поддержку.
      Чтобы отменить — отправьте /cancel`,
  support_new_message: "📩 Новое сообщение в поддержку",
  support_message_sent: "✅ Сообщение отправлено в поддержку. Спасибо!",
  support_message_error: "❌ Ошибка при отправке сообщения.",
  support_message_canceled: "❌ Отправка отменена.",
  support_name_user: "📛 Имя:",
  support_message: "💬 Сообщение:",

  // Ошибки
  error_generic: "❌ Произошла ошибка. Попробуйте ещё раз.",

  requests_limit: "⛔ Слишком много запросов. Попробуйте позже.",
};

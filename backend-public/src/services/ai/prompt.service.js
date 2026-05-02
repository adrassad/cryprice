export function buildBotPrompt({ userText, profile, locale = "ru" }) {
  const languageInstruction =
    locale === "ru"
      ? "Отвечай на русском языке, кратко и понятно."
      : "Reply in English, clearly and concisely.";

  const profileContext = profile
    ? `Профиль пользователя:
- telegramId: ${profile.telegramId}`
    : "Профиль пользователя недоступен.";

  return `
Ты помощник внутри Telegram-бота по DeFi и кошелькам.
${languageInstruction}

Правила:
- Не выдумывай факты.
- Если данных недостаточно, прямо скажи об этом.
- Для простых вопросов отвечай кратко.
- Для инструкций давай пошаговый ответ.
- Не используй markdown-таблицы.
- Не отвечай слишком длинно.

${profileContext}

Запрос пользователя:
${userText}
  `.trim();
}

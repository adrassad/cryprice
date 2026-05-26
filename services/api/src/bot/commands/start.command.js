//src/bot/commands/start.command.js
import {
  getUserByTelegramId,
  findUserByTelegramId,
} from "../../services/user/user.service.js";
import { consumeTelegramLinkToken } from "../../services/auth/auth.service.js";
import { mainKeyboard } from "../keyboards/main.keyboard.js";
import { t } from "../locales/index.js";

async function resolveLinkedTelegramUser(telegramId) {
  return (
    (await getUserByTelegramId(telegramId)) ??
    (await findUserByTelegramId(telegramId))
  );
}

export function startCommand(bot) {
  bot.telegram.setMyCommands(
    [
      { command: "start", description: "🚀 Перезапустить бота" },
      { command: "profile", description: "💳 Ваш профиль" },
      { command: "add_wallet", description: "➕ Добавить кошелек" },
      {
        command: "set_threshold",
        description: "🎚️Установить порог Health Factor",
      },
      { command: "positions", description: "📊 Показать мои позиции" },
      {
        command: "healthfactor",
        description: "🛡 Показать healthfactor на Aave",
      },
      { command: "help", description: "❓ Показать все команды" },
      { command: "support", description: "💬 Написать в поддержку" },
    ],
    { language_code: "ru" },
  );

  bot.telegram.setMyCommands(
    [
      { command: "start", description: "🚀 Restart bot" },
      { command: "profile", description: "💳 Your profile" },
      { command: "add_wallet", description: "➕ Add wallet" },
      {
        command: "set_threshold",
        description: "🎚️Set threshold Health Factor",
      },
      { command: "positions", description: "📊 Show my positions" },
      { command: "healthfactor", description: "🛡 Show Aave healthfactor" },
      { command: "help", description: "❓ Show all commands" },
      { command: "support", description: "💬 Contact support" },
    ],
    { language_code: "en" },
  );
  bot.start(async (ctx) => {
    if (ctx.scene?.current) {
      await ctx.scene.leave();
    }

    const telegramId = ctx.from.id;
    const text = String(ctx.message?.text ?? "");
    const payload = text.startsWith("/start ") ? text.slice(7).trim() : "";

    if (payload.startsWith("link_")) {
      const rawToken = payload.slice("link_".length);
      try {
        await consumeTelegramLinkToken(rawToken, ctx.from);
        await ctx.reply(t(ctx.from.language_code, "start_link_success"), {
          parse_mode: "HTML",
          ...mainKeyboard(ctx.from.language_code),
        });
      } catch (e) {
        await ctx.reply(t(ctx.from.language_code, "start_link_failed"), {
          parse_mode: "HTML",
        });
      }
      return;
    }

    const user = await resolveLinkedTelegramUser(telegramId);

    if (user) {
      await ctx.reply(t(ctx.from.language_code, "start_linked_success"), {
        parse_mode: "HTML",
        ...mainKeyboard(ctx.from.language_code),
      });
      return;
    }

    await ctx.reply(t(ctx.from.language_code, "start_not_linked"), {
      parse_mode: "HTML",
    });
  });
}

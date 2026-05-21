//src/bot/commands/start.command.js
import { createIfNotExists } from "../../services/user/user.service.js";
import { mainKeyboard } from "../keyboards/main.keyboard.js";
import { t } from "../locales/index.js";

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
    await createIfNotExists(ctx.from);

    await ctx.reply(t(ctx.from.language_code, "start_welcome"), {
      parse_mode: "HTML",
      ...mainKeyboard(ctx.from.language_code),
    });
  });
}

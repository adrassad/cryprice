import { t } from "../locales/index.js";

//src/bot/commands/help.command.js
export function helpCommand(bot) {
  bot.command("help", async (ctx) => {
    await ctx.reply(t(ctx.from.language_code, "help_command"));
  });
}

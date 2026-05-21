// src/bot/commands/support.command.js
import { t } from "../locales/index.js";

/** Public export: no admin relay — users see README / issue tracker for contact. */
export function supportCommand(bot) {
  bot.command("support", async (ctx) => {
    await ctx.reply(t(ctx.from.language_code, "support_public_notice"));
  });
}

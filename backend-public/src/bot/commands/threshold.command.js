// bot/commands/threshold.command.js
import { t } from "../locales/index.js";
import { updateUser } from "../../services/user/user.service.js";

function parseThreshold(value) {
  if (!value) return null;

  const normalized = value.trim().replace(",", ".");
  const parsed = Number(normalized);

  if (!Number.isFinite(parsed)) return null;
  if (parsed <= 0) return null;

  return parsed;
}

export function thresholdCommand(bot) {
  bot.command("set_threshold", async (ctx) => {
    ctx.session.awaitingThreshold = true;

    await ctx.reply(t(ctx.from.language_code, "threshhold_enter"));
  });

  bot.command("cancel", async (ctx) => {
    if (ctx.session?.awaitingThreshold) {
      ctx.session.awaitingThreshold = false;
      await ctx.reply(t(ctx.from.language_code, "action_cancel"));
      return;
    }

    await ctx.reply(t(ctx.from.language_code, "nothing_to_cancel"));
  });

  bot.on("text", async (ctx, next) => {
    if (!ctx.session?.awaitingThreshold) {
      return next();
    }

    const message = ctx.message.text;

    if (message.startsWith("/")) {
      return next();
    }

    const threshold = parseThreshold(message);

    if (threshold === null) {
      await ctx.reply(t(ctx.from.language_code, "threshold_error"));
      return;
    }

    const userId = ctx.from.id;
    const user = await updateUser(userId, { threshold_hf: threshold });

    ctx.session.awaitingThreshold = false;

    await ctx.reply(
      t(ctx.from.language_code, "threshold_updated") + (user?.threshold_hf ?? ""),
    );
  });
}

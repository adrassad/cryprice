import {
  getUserByTelegramId,
  findUserByTelegramId,
} from "../../services/user/user.service.js";
import { t } from "../locales/index.js";
import {
  normalizeBotCommand,
  shouldBypassLinkedUserCheck,
} from "./requireLinkedTelegramUser.bypass.js";

async function resolveLinkedTelegramUser(telegramId) {
  return (
    (await getUserByTelegramId(telegramId)) ??
    (await findUserByTelegramId(telegramId))
  );
}

export function requireLinkedTelegramUser() {
  return async (ctx, next) => {
    if (!ctx.from) {
      return next();
    }

    if (shouldBypassLinkedUserCheck(ctx)) {
      return next();
    }

    const telegramId = ctx.from.id;
    const updateType = ctx.updateType;

    try {
      const user = await resolveLinkedTelegramUser(telegramId);

      if (user) {
        ctx.state.user = user;
        return next();
      }

      if (ctx.callbackQuery) {
        try {
          await ctx.answerCbQuery();
        } catch {}
      }

      await ctx.reply(t(ctx.from.language_code, "start_not_linked"), {
        parse_mode: "HTML",
      });
    } catch (error) {
      console.error("requireLinkedTelegramUser middleware error", {
        telegramId,
        updateType,
        command: normalizeBotCommand(ctx.message?.text),
        error: error?.message ?? "unknown",
      });

      try {
        await ctx.reply(t(ctx.from.language_code, "error"));
      } catch {}
    }
  };
}

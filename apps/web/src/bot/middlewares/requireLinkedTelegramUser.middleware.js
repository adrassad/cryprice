import { ENV } from "../../config/env.js";
import {
  getUserByTelegramId,
  findUserByTelegramId,
} from "../../services/user/user.service.js";
import { t } from "../locales/index.js";
import { isActiveSupportSession } from "../commands/support.command.js";

const ADMIN_TELEGRAM_ID = Number(ENV.ADMIN_ID);

/**
 * @param {string} token
 * @returns {string}
 */
export function normalizeBotCommand(token) {
  const trimmed = String(token ?? "").trim();
  if (!trimmed.startsWith("/")) {
    return "";
  }
  return trimmed.split("@")[0].toLowerCase();
}

/**
 * @param {import('telegraf').Context} ctx
 * @returns {boolean}
 */
export function shouldBypassLinkedUserCheck(ctx) {
  if (!ctx.from) {
    return true;
  }

  if (isAdminTelegramUser(ctx.from.id)) {
    return true;
  }

  const text = String(ctx.message?.text ?? "").trim();
  if (text) {
    const command = normalizeBotCommand(text.split(/\s+/)[0]);

    if (command === "/start" || command === "/help" || command === "/support") {
      return true;
    }

    if (command === "/cancel") {
      if (isActiveSupportSession(ctx.from.id)) {
        return true;
      }
      if (ctx.session?.awaitingThreshold) {
        return true;
      }
      if (ctx.scene?.current) {
        return true;
      }
    }
  }

  if (ctx.message?.text && isActiveSupportSession(ctx.from.id)) {
    return true;
  }

  return false;
}

/**
 * @param {number | string | undefined} telegramId
 * @returns {boolean}
 */
export function isAdminTelegramUser(telegramId) {
  if (!Number.isFinite(ADMIN_TELEGRAM_ID)) {
    return false;
  }
  return String(telegramId) === String(ADMIN_TELEGRAM_ID);
}

/**
 * Lookup-only gate: web account must be linked before bot features run.
 */
export function requireLinkedTelegramUser() {
  return async function requireLinkedTelegramUserMiddleware(ctx, next) {
    if (!ctx.from) {
      return next();
    }

    if (shouldBypassLinkedUserCheck(ctx)) {
      return next();
    }

    const telegramId = ctx.from.id;
    const updateType = ctx.updateType ?? "unknown";
    const commandHint = ctx.message?.text
      ? String(ctx.message.text).trim().split(/\s+/)[0]
      : ctx.callbackQuery?.data ?? null;

    try {
      const user =
        (await getUserByTelegramId(telegramId)) ??
        (await findUserByTelegramId(telegramId));

      if (user) {
        ctx.state.user = user;
        return next();
      }

      await ctx.reply(t(ctx.from.language_code, "start_not_linked"), {
        parse_mode: "HTML",
      });
    } catch (error) {
      console.error("requireLinkedTelegramUser middleware error", {
        at: new Date().toISOString(),
        telegramId,
        updateType,
        command: commandHint,
        message: error?.message ?? "unknown",
      });

      await ctx.reply(t(ctx.from.language_code, "error_generic"), {
        parse_mode: "HTML",
      });
    }
  };
}

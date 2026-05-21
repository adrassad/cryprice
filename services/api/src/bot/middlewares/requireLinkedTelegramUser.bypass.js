import { isActiveSupportSession } from "../commands/support.command.js";

/**
 * @param {string | undefined | null} text
 * @returns {string | null}
 */
export function normalizeBotCommand(text) {
  const trimmed = String(text ?? "").trim();
  if (!trimmed.startsWith("/")) return null;
  const firstToken = trimmed.split(/\s+/)[0];
  return firstToken.split("@")[0].toLowerCase();
}

/**
 * @param {import("telegraf").Context} ctx
 * @returns {boolean}
 */
export function shouldBypassLinkedUserCheck(ctx) {
  if (!ctx.from) return true;

  const text = String(ctx.message?.text ?? "").trim();
  const command = normalizeBotCommand(text);

  if (command === "/start" || command === "/help" || command === "/support") {
    return true;
  }

  if (command === "/cancel" && isActiveSupportSession(ctx.from.id)) {
    return true;
  }

  if (text && !text.startsWith("/") && isActiveSupportSession(ctx.from.id)) {
    return true;
  }

  return false;
}

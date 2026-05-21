//src/bot/handlers/error.handler.js
import { ERRORS } from "../constants/errors.js";
import { t } from "../locales/index.js";

export function registerGlobalErrorHandler(bot) {
  bot.catch(async (error, ctx) => {
    await handleBotError(ctx, error);
  });
}

async function handleBotError(ctx, error) {
  const code = error.code || error.message;

  switch (code) {
    case ERRORS.INVALID_ADDRESS:
      return ctx.reply(t(ctx.from.language_code, "novalid_address"));

    case ERRORS.WALLET_ALREADY_EXISTS:
      return ctx.reply(t(ctx.from.language_code, "wallets.wallet_you_have"));

    case ERRORS.WALLET_LIMIT_REACHED:
      return ctx.reply(t(ctx.from.language_code, "wallet_limit_reached"));

    case ERRORS.WALLET_NOT_FOUND:
      return ctx.reply(t(ctx.from.language_code, "wallets.no_wallet"));

    case ERRORS.USER_NOT_FOUND:
      return ctx.reply(t(ctx.from.language_code, "no_user"));

    default:
      console.error("UNHANDLED ERROR:", new Date().toISOString(), error);
      return ctx.reply(t(ctx.from.language_code, "error"));
  }
}

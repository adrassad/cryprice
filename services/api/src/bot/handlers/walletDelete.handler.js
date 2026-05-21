// src/bot/handlers/walletDelete.handler.js
import { removeUserWallet } from "../../services/wallet/wallet.service.js";
import { t } from "../locales/index.js";

export function walletDeleteHandler(bot) {
  bot.action(/^WALLET_DELETE:/, async (ctx) => {
    const userId = ctx.from.id;
    const walletId = ctx.callbackQuery.data.split(":")[1];

    try {
      await removeUserWallet(userId, walletId);

      await ctx.answerCbQuery(
        t(ctx.from.language_code, "wallets.wallet_deleted"),
      );
      await ctx.editMessageText(
        t(ctx.from.language_code, "wallets.wallet_deleted_success"),
      );
    } catch (e) {
      console.error("Error deleting wallet:", e, new Date().toISOString());
      await ctx.answerCbQuery(
        t(ctx.from.language_code, "wallets.wallet_deleted_error"),
      );
      await ctx.reply(
        t(ctx.from.language_code, "wallets.wallet_deleted_failed"),
      );
    }
  });
}

// src/bot/handlers/walletDelete.handler.js
import { removeUserWallet } from "../../services/wallet/wallet.service.js";
import { t } from "../locales/index.js";
import { getUserByTelegramId } from "../../services/user/user.service.js";

export function walletDeleteHandler(bot) {
  bot.action(/^WALLET_DELETE:/, async (ctx) => {
    const user = await getUserByTelegramId(ctx.from.id);
    if (!user) {
      await ctx.answerCbQuery(t(ctx.from.language_code, "profile.notFound"));
      return;
    }
    const walletId = ctx.callbackQuery.data.split(":")[1];

    try {
      await removeUserWallet(user.id, walletId);

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

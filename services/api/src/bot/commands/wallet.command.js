// src/bot/commands/wallet.command.js

import { SCENES } from "../constants/scenes.js";
import { t } from "../locales/index.js";

export function walletCommand(bot) {
  bot.command("add_wallet", async (ctx) => {
    try {
      const userId = ctx.from.id;
      console.log(`User ${userId} triggered /add_wallet`);
      await ctx.scene.enter(SCENES.ADD_WALLET);
    } catch (error) {
      console.error(
        "add_wallet command error:",
        new Date().toISOString(),
        error,
      );

      await ctx.reply(
        t(ctx.from.language_code, "wallet_error") ||
          "❌ Failed to start wallet adding process",
      );
    }
  });
}

import { Scenes, Markup } from "telegraf";
import { SCENES } from "../constants/scenes.js";
import { getUserWallets } from "../../services/wallet/wallet.service.js";
import { t } from "../locales/index.js";
import { getUserByTelegramId } from "../../services/user/user.service.js";

export const removeWalletScene = new Scenes.BaseScene(SCENES.REMOVE_WALLET);

removeWalletScene.enter(async (ctx) => {
  const user = await getUserByTelegramId(ctx.from.id);
  if (!user) {
    await ctx.reply(t(ctx.from.language_code, "profile.notFound"));
    return ctx.scene.leave();
  }
  const userId = user.id;

  const wallets = await getUserWallets(userId);

  if (!wallets.size) {
    await ctx.reply(t(ctx.from.language_code, "command_wallet_no_add"));
    return ctx.scene.leave();
  }

  const buttons = [];

  wallets.forEach((value, key) => {
    buttons.push(
      Markup.button.callback(value.address, `WALLET_DELETE:${value.address}`),
    );
  });

  await ctx.reply(
    t(ctx.from.language_code, "wallets.wallet_select_delete"),
    Markup.inlineKeyboard(buttons, { columns: 1 }),
  );
});

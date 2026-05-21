// src/bot/scenes/addWallet.scene.js
import { Scenes } from "telegraf";
import { SCENES } from "../constants/scenes.js";
import { button } from "../constants/buttons.js";
import { addUserWallet } from "../../services/wallet/wallet.service.js";
import { handleReturn } from "../utils/returnTo.js";
import { t } from "../locales/index.js";
import {
  getUserByTelegramId,
  findUserByTelegramId,
} from "../../services/user/user.service.js";

export const addWalletScene = new Scenes.BaseScene(SCENES.ADD_WALLET);

async function resolveLinkedTelegramUser(telegramId) {
  return (
    (await getUserByTelegramId(telegramId)) ??
    (await findUserByTelegramId(telegramId))
  );
}

/**
 * Вход в сцену
 */
addWalletScene.enter(async (ctx) => {
  const user = await resolveLinkedTelegramUser(ctx.from.id);
  if (!user) {
    await ctx.reply(t(ctx.from.language_code, "start_not_linked"), {
      parse_mode: "HTML",
    });
    await ctx.scene.leave();
    return;
  }

  await ctx.reply(t(ctx.from.language_code, "wallets.wallet_send"), {
    parse_mode: "Markdown",
  });
});

/**
 * Отмена
 */
addWalletScene.command("cancel", async (ctx) => {
  await ctx.reply(t(ctx.from.language_code, "wallets.wallet_send_canceled"));
  await ctx.scene.leave();
  await handleReturn(ctx);
});

/**
 * Обработка текста
 */
addWalletScene.on("text", async (ctx) => {
  const text = ctx.message.text.trim();

  // ❗ Игнорируем кнопки меню
  if (Object.values(button(ctx.from.language_code)).includes(text)) {
    return ctx.reply(t(ctx.from.language_code, "wallets.wallet_sending"));
  }

  // ❗ Игнорируем команды
  if (text.startsWith("/")) {
    return ctx.reply(t(ctx.from.language_code, "wallets.wallet_send"));
  }

  const user = await resolveLinkedTelegramUser(ctx.from.id);
  if (!user) {
    await ctx.reply(t(ctx.from.language_code, "start_not_linked"), {
      parse_mode: "HTML",
    });
    await ctx.scene.leave();
    return;
  }

  await addUserWallet(user.id, text);

  await ctx.reply(t(ctx.from.language_code, "wallets.wallet_added"));
  await ctx.scene.leave();
  await handleReturn(ctx);
});

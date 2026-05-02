//src/bot/handlers/walletAdd.handler.js
import { button } from "../constants/buttons.js";
import { SCENES } from "../constants/scenes.js";
import { RETURNS } from "../constants/returns.js";

export function walletAddHears(bot) {
  const ADD_WALLET_TRIGGERS = [
    button("ru").ADD_WALLET,
    button("en").ADD_WALLET,
  ];

  bot.hears(ADD_WALLET_TRIGGERS, async (ctx) => {
    ctx.session.returnTo = RETURNS.MAIN_MENU;
    await ctx.scene.enter(SCENES.ADD_WALLET);
  });
}

//src/bot/utils/returnTo.js
import { RETURNS } from "../constants/returns.js";
import { mainKeyboard } from "../keyboards/main.keyboard.js";
import { t } from "../locales/index.js";

export async function handleReturn(ctx) {
  const target = ctx.session.returnTo;

  // очистка
  delete ctx.session.returnTo;

  switch (target) {
    case RETURNS.MAIN_MENU:
      await ctx.reply(t(ctx.from.language_code, "main_menu"), mainKeyboard());
      break;

    default:
      // если returnTo не задан
      break;
  }
}

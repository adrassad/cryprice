//src/bot/constants/buttons.js
import { t } from "../locales/index.js";

// src/bot/constants/buttons.js
export function button(lan = "en") {
  return Object.freeze({
    ADD_WALLET: t(lan, "wallets.wallet_buttom_add"),
    REMOVE_WALLET: t(lan, "wallets.wallet_buttom_del"),
  });
}

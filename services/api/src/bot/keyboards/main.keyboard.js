// src/bot/keyboards/main.keyboard.js
import { Markup } from "telegraf";
import { button } from "../constants/buttons.js";

export function mainKeyboard(lang = "en") {
  return Markup.keyboard([
    [button(lang).ADD_WALLET, button(lang).REMOVE_WALLET],
  ]).resize();
}

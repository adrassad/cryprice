import { walletAddHears } from "./walletAdd.handler.js";
import { walletDeleteHandler } from "./walletDelete.handler.js";
import { walletRemoveHandler } from "./walletRemove.handler.js";
import { registerGlobalErrorHandler } from "./error.handler.js";
import { tokenPriceHandler } from "./tokenPrice.handler.js";
import { thresholdCommand } from "../commands/threshold.command.js";
import { aiMessageHandler } from "./aiMessage.handler.js";

export function registerHandlers(bot) {
  aiMessageHandler(bot);
  walletAddHears(bot);
  walletRemoveHandler(bot);
  walletDeleteHandler(bot);
  registerGlobalErrorHandler(bot);
  tokenPriceHandler(bot);
  thresholdCommand(bot);
}

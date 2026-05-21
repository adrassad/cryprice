//src/bot/commands/index.js
import { startCommand } from "./start.command.js";
import { helpCommand } from "./help.command.js";
import { profileCommand } from "./profile.command.js";
import { positionsCommand } from "./positions.command.js";
import { healthFactorCommand } from "./healthfactor.command.js";
import { supportCommand } from "./support.command.js";
import { thresholdCommand } from "./threshold.command.js";
import { walletCommand } from "./wallet.command.js";

export function registerCommands(bot) {
  startCommand(bot);
  profileCommand(bot);
  helpCommand(bot);
  positionsCommand(bot);
  healthFactorCommand(bot);
  supportCommand(bot);
  thresholdCommand(bot);
  walletCommand(bot);
}

// healthfactor.service.js

import { ENV } from "../../config/env.js";
import { collectHealthFactors } from "./healthfactor.collector.js";
import { NotificationService } from "../../bot/notification.service.js";
import { formatHealthFactorOverview } from "../../bot/utils/hfFormatter.js";
import { getUserByInternalId } from "../user/user.service.js";
import { evaluateHealthFactorAlerts } from "../alerts/healthFactorAlert.service.js";
import { deliverPendingAlerts } from "../alerts/alertDelivery.service.js";

async function sendLegacyHfTelegramAlerts(resultMap) {
  await Promise.allSettled(
    [...resultMap.entries()].map(async ([userId, walletMap]) => {
      const user = await getUserByInternalId(userId);
      if (user?.telegram_id == null) {
        console.warn("[HF] skip notify: no telegram_id", { userId });
        return;
      }
      await NotificationService.sendToUser(
        user.telegram_id,
        formatHealthFactorOverview(walletMap),
        { parse_mode: "HTML" },
      );
    }),
  );
}

async function runTelegramAlertDelivery() {
  try {
    const stats = await deliverPendingAlerts({ channel: "telegram", limit: 50 });
    console.log("[HF] telegram alert delivery completed", stats);
  } catch (err) {
    console.error(
      "[HF] telegram alert delivery failed:",
      new Date().toISOString(),
      err?.message ?? err,
    );
  }
}

async function runHfAlertEvaluation() {
  try {
    console.log("[HF] alerts v2 evaluation starting");
    const stats = await evaluateHealthFactorAlerts();
    console.log("[HF] alerts v2 evaluation completed", stats);
  } catch (err) {
    console.error(
      "[HF] alerts v2 evaluation failed:",
      new Date().toISOString(),
      err?.message ?? err,
    );
  } finally {
    void runTelegramAlertDelivery();
  }
}

export async function syncHF() {
  console.log("⏱ HealthFactor sync started");
  console.time("HF_SYNC");

  const resultMap = await collectHealthFactors({
    checkChange: true,
  });

  if (ENV.ALERTS_V2_ENABLED) {
    console.log(
      "[HF] legacy Telegram alerts skipped (ALERTS_V2_ENABLED=true)",
    );
    void runHfAlertEvaluation();
  } else {
    await sendLegacyHfTelegramAlerts(resultMap);
  }

  console.timeEnd("HF_SYNC");
}

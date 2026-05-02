// healthfactor.service.js

import { collectHealthFactors } from "./healthfactor.collector.js";
import { NotificationService } from "../../bot/notification.service.js";
import { formatHealthFactorOverview } from "../../bot/utils/hfFormatter.js";

export async function syncHF() {
  console.log("⏱ HealthFactor sync started");
  console.time("HF_SYNC");

  const resultMap = await collectHealthFactors({
    checkChange: true,
  });

  await Promise.allSettled(
    [...resultMap.entries()].map(([userId, walletMap]) =>
      NotificationService.sendToUser(
        userId,
        formatHealthFactorOverview(walletMap),
        { parse_mode: "HTML" },
      ),
    ),
  );

  console.timeEnd("HF_SYNC");
}

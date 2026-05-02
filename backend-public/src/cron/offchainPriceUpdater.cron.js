import cron from "node-cron";
import { runOffchainBulkSyncIfIdle } from "../services/price/offchainPriceIngestion.service.js";

export async function startOffchainPriceSyncCron() {
  try {
    await runOffchainBulkSyncIfIdle();
  } catch (e) {
    console.error(
      "❌ Off-chain price updater failed:",
      new Date().toISOString(),
      e,
    );
  }
}

/** Register the recurring job. Call from startCrons() only — not at module import time. */
export function scheduleOffchainPriceCron() {
  return cron.schedule("*/5 * * * *", startOffchainPriceSyncCron);
}

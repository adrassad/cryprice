// src/cron/HFUpdater.cron.js
import cron from "node-cron";
import { syncHF } from "../services/healthfactor/healthfactor.service.js";

let isRunning = false;

export async function startHFSyncCron() {
  if (isRunning) {
    console.log(
      "⏭ HealthFactor sync already running",
      new Date().toISOString(),
    );
    return;
  }
  isRunning = true;

  console.log("⏱ Updating HealthFactor...", new Date().toISOString());

  try {
    await syncHF();
    console.log(
      "✅ HealthFactor sync completed successfully",
      new Date().toISOString(),
    );
  } catch (e) {
    console.error(
      "❌ HealthFactor updater failed:",
      new Date().toISOString(),
      e,
    );
  } finally {
    isRunning = false;
  }
}

/** Register the recurring job. Call from startCrons() only — not at module import time. */
export function scheduleHFCron() {
  return cron.schedule("*/5 * * * *", startHFSyncCron);
}

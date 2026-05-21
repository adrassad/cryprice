import cron from "node-cron";
import { syncAaveProtocolAssetTokens } from "../services/protocolAsset/protocolAsset.service.js";

const STARTUP_DELAY_MS = 60_000;

let isRunning = false;
let startupSyncTimer = null;

export async function runProtocolAssetTokenSync({ reason = "manual" } = {}) {
  if (isRunning) {
    console.log(
      `⏭ Protocol asset token sync skipped — already running (${reason})`,
      new Date().toISOString(),
    );
    return;
  }
  isRunning = true;

  console.log(
    `⏱ Protocol asset token sync started (${reason})`,
    new Date().toISOString(),
  );

  try {
    const summary = await syncAaveProtocolAssetTokens();
    console.log(
      `✅ Protocol asset token sync completed (${reason})`,
      new Date().toISOString(),
      summary,
    );
  } catch (e) {
    console.error(
      `❌ Protocol asset token sync failed (${reason}):`,
      new Date().toISOString(),
      e,
    );
  } finally {
    isRunning = false;
  }
}

export async function startProtocolAssetSyncCron() {
  return runProtocolAssetTokenSync({ reason: "cron" });
}

/** Register the recurring job. Call from startCrons() only — not at module import time. */
export function scheduleProtocolAssetCron() {
  return cron.schedule("30 3 * * *", startProtocolAssetSyncCron, {
    scheduled: true,
    timezone: "UTC",
  });
}

/**
 * One delayed post-startup run to populate metadata after deploy without blocking API startup.
 */
export function scheduleProtocolAssetStartupSync(delayMs = STARTUP_DELAY_MS) {
  if (startupSyncTimer) {
    console.log(
      "⏭ Protocol asset delayed startup sync already scheduled",
      new Date().toISOString(),
    );
    return startupSyncTimer;
  }

  console.log(
    `⏳ Protocol asset delayed startup sync scheduled in ${delayMs}ms`,
    new Date().toISOString(),
  );

  startupSyncTimer = setTimeout(() => {
    console.log(
      "⏱ Protocol asset delayed startup sync triggered",
      new Date().toISOString(),
    );
    void runProtocolAssetTokenSync({ reason: "startup_delayed" });
  }, delayMs);

  return startupSyncTimer;
}

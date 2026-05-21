// src/cron/portfolioUpdater.cron.js
import cron from "node-cron";
import { syncAllWalletPortfolios } from "../services/portfolio/portfolio.service.js";

const STARTUP_DELAY_MS = 60_000;

let isRunning = false;
let startupSyncTimer = null;

export async function startPortfolioSyncCron() {
  if (isRunning) {
    console.log(
      "⏭ Portfolio sync already running",
      new Date().toISOString(),
    );
    return;
  }
  isRunning = true;

  console.log("⏱ Portfolio batch sync...", new Date().toISOString());

  try {
    const stats = await syncAllWalletPortfolios();
    console.log(
      "✅ Portfolio batch sync finished",
      new Date().toISOString(),
      stats,
    );
  } catch (e) {
    console.error(
      "❌ Portfolio cron unexpected failure:",
      new Date().toISOString(),
      e,
    );
  } finally {
    isRunning = false;
  }
}

/** Register the recurring job. Call from startCrons() only — not at module import time. */
export function schedulePortfolioCron() {
  return cron.schedule("*/5 * * * *", startPortfolioSyncCron, {
    scheduled: true,
    timezone: "UTC",
  });
}

/**
 * One delayed post-startup run to populate wallet portfolio and protocol positions
 * without blocking API startup.
 */
export function schedulePortfolioStartupSync(delayMs = STARTUP_DELAY_MS) {
  if (startupSyncTimer) {
    console.log(
      "⏭ Portfolio delayed startup sync already scheduled",
      new Date().toISOString(),
    );
    return startupSyncTimer;
  }

  console.log(
    `⏳ Portfolio delayed startup sync scheduled in ${delayMs}ms`,
    new Date().toISOString(),
  );

  startupSyncTimer = setTimeout(() => {
    console.log(
      "⏱ Portfolio delayed startup sync triggered",
      new Date().toISOString(),
    );
    void startPortfolioSyncCron();
  }, delayMs);

  return startupSyncTimer;
}

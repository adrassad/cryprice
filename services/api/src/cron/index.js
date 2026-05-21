//src/cron/index.js

/**
 * Explicit cron lifecycle: importing cron modules does not register schedules.
 * All schedules are registered here when startCrons() runs (once per process).
 */
let cronsStartPromise = null;

export async function startCrons() {
  if (cronsStartPromise) return cronsStartPromise;

  cronsStartPromise = (async () => {
    console.log("🕒 Starting cron jobs...", new Date().toISOString());

    const { scheduleAssetsCron } = await import("./assetsUpdater.cron.js");
    scheduleAssetsCron();

    const { startPriceSyncCron, schedulePriceCron } = await import(
      "./priceUpdater.cron.js",
    );
    schedulePriceCron();
    await startPriceSyncCron();

    const { startOffchainPriceSyncCron, scheduleOffchainPriceCron } =
      await import("./offchainPriceUpdater.cron.js");
    scheduleOffchainPriceCron();
    // Do not await: full off-chain sync (esp. CoinGecko 429 retries) must not block HTTP listen.
    void startOffchainPriceSyncCron();

    const { startHFSyncCron, scheduleHFCron } = await import(
      "./HFUpdater.cron.js",
    );
    scheduleHFCron();
    await startHFSyncCron();
  })();

  return cronsStartPromise;
}

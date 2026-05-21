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

    const { scheduleProtocolAssetCron, scheduleProtocolAssetStartupSync } =
      await import("./protocolAssetUpdater.cron.js");
    scheduleProtocolAssetCron();
    scheduleProtocolAssetStartupSync();

    const { startPriceSyncCron, schedulePriceCron } = await import(
      "./priceUpdater.cron.js"
    );
    schedulePriceCron();
    await startPriceSyncCron();

    const { startOffchainPriceSyncCron, scheduleOffchainPriceCron } =
      await import("./offchainPriceUpdater.cron.js");
    scheduleOffchainPriceCron();
    void startOffchainPriceSyncCron();

    const { startHFSyncCron, scheduleHFCron } = await import(
      "./HFUpdater.cron.js"
    );
    scheduleHFCron();
    await startHFSyncCron();

    const { schedulePortfolioCron, schedulePortfolioStartupSync } =
      await import("./portfolioUpdater.cron.js");
    schedulePortfolioCron();
    schedulePortfolioStartupSync();

    const { scheduleTokenIconCron, scheduleTokenIconStartupSync } =
      await import("./tokenIconUpdater.cron.js");
    scheduleTokenIconCron();
    scheduleTokenIconStartupSync();
  })();

  return cronsStartPromise;
}

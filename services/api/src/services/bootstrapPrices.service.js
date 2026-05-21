import { loadLastPricesToCache } from "./price/price.service.js";
import { runOffchainBulkSyncIfIdle } from "./price/offchainPriceIngestion.service.js";

export async function bootstrapPricesService() {
  await loadLastPricesToCache();
  console.log(
    "🌐 Prices: on-chain cache loaded; API startup will not wait for off-chain bulk sync",
    new Date().toISOString(),
  );
  void runOffchainBulkSyncIfIdle();
  console.log(
    "🌐 Prices bootstrapped (off-chain warmup scheduled in background)",
    new Date().toISOString(),
  );
}

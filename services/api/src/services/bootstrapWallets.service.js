import { loadWalletsToCache } from "./wallet/wallet.service.js";

export async function bootstrapWalletsService() {
  await loadWalletsToCache();
  console.log("🌐 Wallets bootstrapped", new Date().toISOString());
}

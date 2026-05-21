// src/services/aave/positions.collector.js
import pLimit from "p-limit";
import { getEnabledNetworks } from "../network/network.service.js";
import { getAllWallets, getUserWallets } from "../wallet/wallet.service.js";
import { getWalletPositions } from "./position.service.js";

const CONCURRENCY = 5; // общий лимит RPC

export async function collectPositions({ userId = null, walletId = null }) {
  const networks = await getEnabledNetworks();
  const limit = pLimit(CONCURRENCY);

  const resultMap = new Map();
  const tasks = [];

  let wallets;

  // 🟢 1. Определяем источник кошельков
  if (userId && walletId) {
    const userWallets = await getUserWallets(userId);
    //const wallet = userWallets.find((w) => w.id === walletId);
    const wallet = [...userWallets.values()].find((w) => w.id === walletId);
    if (!wallet) return new Map();

    wallets = new Map();
    wallets.set(wallet.address, [wallet]);
  } else if (userId) {
    const userWallets = await getUserWallets(userId);
    wallets = new Map();
    for (const wallet of userWallets.values()) {
      if (!wallets.has(wallet.address)) wallets.set(wallet.address, []);
      wallets.get(wallet.address).push(wallet);
    }
  } else {
    wallets = await getAllWallets();
  }

  // 🟢 2. Сбор позиций
  for (const [address, records] of wallets.entries()) {
    for (const record of records) {
      tasks.push(
        limit(async () => {
          try {
            const positions = await getWalletPositions(record.user_id, address);

            if (!resultMap.has(record.user_id)) {
              resultMap.set(record.user_id, new Map());
            }

            const walletMap = resultMap.get(record.user_id);

            if (!walletMap.has(address)) {
              walletMap.set(address, new Map());
            }

            for (const network of Object.values(networks)) {
              walletMap.get(address).set(network.name, positions[network.name]);
            }
          } catch (err) {
            console.error(
              `Positions error: wallet=${address}`,
              new Date().toISOString(),
              err.message,
            );
          }
        }),
      );
    }
  }

  await Promise.allSettled(tasks);

  return resultMap;
}

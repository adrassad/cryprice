import { connectRedis, redis } from "../redis/redis.client.js";

const TTL_SEC = 60 * 120;

function portfolioWalletKey(walletId) {
  return `portfolio:wallet:${String(walletId)}`;
}

export async function getPortfolioByWalletId(walletId) {
  if (walletId == null || walletId === "") return null;
  if (!redis || redis.status === "end") return null;
  if (redis.status !== "ready") await connectRedis();

  try {
    const raw = await redis.get(portfolioWalletKey(walletId));
    if (!raw) return null;
    return JSON.parse(raw);
  } catch (err) {
    console.warn("⚠️ Redis getPortfolioByWalletId failed:", err.message);
    return null;
  }
}

export async function setPortfolioByWalletId(walletId, payload) {
  if (walletId == null || walletId === "") return;
  if (payload == null || typeof payload !== "object") return;
  if (!redis || redis.status === "end") return;

  try {
    await redis.set(
      portfolioWalletKey(walletId),
      JSON.stringify(payload),
      "EX",
      TTL_SEC,
    );
  } catch (err) {
    console.warn("⚠️ Redis setPortfolioByWalletId failed:", err.message);
  }
}

export async function delPortfolioByWalletId(walletId) {
  if (walletId == null || walletId === "") return;
  if (!redis || redis.status === "end") return;

  try {
    await redis.del(portfolioWalletKey(walletId));
  } catch (err) {
    console.warn("⚠️ Redis delPortfolioByWalletId failed:", err.message);
  }
}

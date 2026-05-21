// src/services/wallet.service.js
import { ethers } from "ethers";
import { db } from "../../db/index.js";
import {
  setAllWalletsToCache,
  getWalletsByUser,
  setWalletsToCache,
  delWalletFromCache,
  getAllWalletsCache,
} from "../../cache/wallet.cache.js";
import { collectUsersWallets } from "./wallet.utils.js";

/** Hard cap per user for the public edition. */
const MAX_WALLETS_PER_USER = Number(process.env.MAX_WALLETS_PER_USER) || 50;

function normalizeAddress(address) {
  return address.trim().toLowerCase();
}

export async function addUserWallet(userId, address, label = null) {
  const count = await db.wallets.countByUserId(userId);
  if (count >= MAX_WALLETS_PER_USER) {
    throw new Error("WALLET_LIMIT_REACHED");
  }

  if (!ethers.isAddress(address)) {
    throw new Error("INVALID_ADDRESS");
  }

  const normalizedAddress = normalizeAddress(address);

  const exists = await db.wallets.walletExists(userId, normalizedAddress);
  if (exists) {
    throw new Error("WALLET_ALREADY_EXISTS");
  }

  const wallet = await db.wallets.create({
    user_id: userId,
    address: normalizedAddress,
    label,
  });
  let mapWallet = await getWalletsByUser(userId);
  if (!mapWallet) mapWallet = new Map();
  mapWallet.set(normalizedAddress, wallet);

  setWalletsToCache(userId, mapWallet);

  return wallet;
}

export async function removeUserWallet(userId, walletAddress) {
  const removed = await db.wallets.deleteUserWallet(userId, walletAddress);

  if (!removed) {
    throw new Error("WALLET_NOT_FOUND");
  }
  delWalletFromCache(userId, walletAddress);
  return removed;
}

export async function getUserWallets(userId) {
  let walletsMap = await getWalletsByUser(userId);

  if (walletsMap && walletsMap.size > 0) {
    return walletsMap;
  }

  const walletsFromDb = await db.wallets.findByUserId(userId);

  const result = new Map();

  for (const wallet of walletsFromDb) {
    result.set(wallet.address, wallet);
  }

  if (result.size > 0) {
    await setWalletsToCache(userId, result);
  }

  return result;
}

export async function getUserWallet(userId, address) {
  const normalizedAddress = normalizeAddress(address);

  let walletsMap = await getWalletsByUser(userId);

  if (walletsMap && walletsMap.size > 0) {
    const wallet = walletsMap.get(normalizedAddress);
    if (wallet) return wallet;
  }

  const walletExists = await db.wallets.walletExists(
    userId,
    normalizedAddress,
  );

  if (!walletExists) return null;

  const walletFromDb = await db.wallets.findByUserAndAddress(
    userId,
    normalizedAddress,
  );
  if (!walletFromDb) return null;

  if (!walletsMap || walletsMap.size === 0) {
    walletsMap = new Map();
  }

  walletsMap.set(normalizedAddress, walletFromDb);
  await setWalletsToCache(userId, walletsMap);

  return walletFromDb;
}

export async function getAllWallets() {
  let wallets = await getAllWalletsCache();

  if (wallets && wallets.size > 0) {
    return wallets;
  }

  setAllWalletsToCache(wallets);

  const walletsArray = Object.values(await db.wallets.findAll());
  const walletsUsers = collectUsersWallets(walletsArray);

  if (walletsUsers.size > 0) {
    await setAllWalletsToCache(walletsUsers);
  }

  return walletsUsers;
}

export async function loadWalletsToCache() {
  const walletsArray = Object.values(await db.wallets.findAll());
  const walletsUsers = collectUsersWallets(walletsArray);
  await setAllWalletsToCache(walletsUsers);
  console.log("✅ Cached wallets:", walletsArray.length);
}

export function serializeWalletForApi(row) {
  if (!row) return null;
  const ca = row.created_at;
  return {
    id: row.id,
    address: row.address,
    label: row.label ?? null,
    created_at:
      ca instanceof Date ? ca.toISOString() : ca != null ? String(ca) : null,
  };
}

export async function listWalletsForUser(userId) {
  const map = await getUserWallets(userId);
  const list = [...map.values()].sort(
    (a, b) => Number(a.id) - Number(b.id),
  );
  return list.map(serializeWalletForApi);
}

export async function updateUserWalletLabel(userId, walletId, label) {
  const updated = await db.wallets.updateLabelForUser(
    userId,
    walletId,
    label,
  );
  if (!updated) {
    throw new Error("WALLET_NOT_FOUND");
  }
  let mapWallet = await getWalletsByUser(userId);
  if (!mapWallet || mapWallet.size === 0) mapWallet = new Map();
  mapWallet.set(updated.address, updated);
  await setWalletsToCache(userId, mapWallet);
  return serializeWalletForApi(updated);
}

export async function removeUserWalletByPk(userId, walletId) {
  const removed = await db.wallets.deleteWalletByIdForUser(
    userId,
    walletId,
  );
  if (!removed) {
    throw new Error("WALLET_NOT_FOUND");
  }
  await delWalletFromCache(userId, removed.address);
  return removed;
}

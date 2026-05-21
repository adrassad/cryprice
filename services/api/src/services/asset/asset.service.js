//src/services/asset.service.js
import { db } from "../../db/index.js";
import {
  getAssetsByNetworkCache,
  setAssetsToCache,
  getAssetCache,
  getAssetBySymbolCache,
} from "../../cache/asset.cache.js";
import { getAssets } from "../../blockchain/index.js";
import { getEnabledNetworks } from "../network/network.service.js";

export async function syncAssets() {
  console.log("⏱ Asset sync started");
  const networks = await getEnabledNetworks();
  await Promise.all(
    Object.values(networks).map(async (network) => {
      console.log(`Asset 🔗${network.name} `, network.id);
      const assets = await getAssets(network.name, "aave");
      await upsertAssets(network.id, assets);
      await loadAssetsToCache(network.id);
    }),
  );
}

/**
 * Загрузка ассетов (из Aave / chain / json)
 */
export async function upsertAssets(network_id, assets) {
  await db.assets.bulkUpsert(
    assets.map((a) => ({
      network_id,
      address: a.address,
      symbol: a.symbol,
      decimals: a.decimals,
    })),
  );
}

/**
 * Получить asset по адресу
 */
export async function getAssetByAddress(networkId, address) {
  if (!address || typeof address !== "string") return null;

  const normalizedAddress = address.toLowerCase();

  // 1️⃣ Сначала ищем в кэше
  const cached = await getAssetCache(networkId, normalizedAddress);
  if (cached) return cached;

  // 2️⃣ Если нет в кэше — ищем в БД
  const asset = await db.assets.findByAddress(networkId, normalizedAddress);
  if (!asset) return null;

  return asset;
}

export async function getAssetBySymbol(symbol) {
  if (!symbol || typeof symbol !== "string") return null;

  const normalizedAddress = symbol.toLowerCase();
  const networks = Object.values(await getEnabledNetworks());

  const netAsset = new Map();
  await Promise.all(
    networks.map(async (network) => {
      const asset = await getAssetBySymbolCache(network.id, symbol);
      if (asset) {
        netAsset.set(network, asset);
      }
    }),
  );
  return netAsset;
}

//Получить все assets
export async function getAllAssets() {
  return await db.assets.findAll();
}

function looksLikeEvmAddress(value) {
  return (
    typeof value === "string" &&
    value.startsWith("0x") &&
    value.length === 42
  );
}

/**
 * Resolve asset by address or symbol for this network. Cache first, then DB (same contract as getAssetByAddress for lookups).
 */
export async function getAsset(networkId, addressOrSymbol) {
  const cached = await getAssetCache(networkId, addressOrSymbol);
  if (cached) return cached;

  const raw = addressOrSymbol?.trim();
  if (!raw) return null;

  if (looksLikeEvmAddress(raw)) {
    const fromDb = await db.assets.findByAddress(networkId, raw.toLowerCase());
    if (fromDb) {
      await setAssetsToCache(networkId, {
        [fromDb.address.toLowerCase()]: {
          id: fromDb.id,
          network_id: fromDb.network_id,
          address: fromDb.address,
          symbol: fromDb.symbol,
          decimals: fromDb.decimals,
        },
      });
    }
    return fromDb;
  }

  const rows = await db.assets.findByNetwork(networkId);
  const fromDb =
    rows.find((r) => r.symbol.toUpperCase() === raw.toUpperCase()) ?? null;
  if (fromDb) {
    await setAssetsToCache(networkId, {
      [fromDb.address.toLowerCase()]: {
        id: fromDb.id,
        network_id: fromDb.network_id,
        address: fromDb.address,
        symbol: fromDb.symbol,
        decimals: fromDb.decimals,
      },
    });
  }
  return fromDb;
}

export async function loadAllAssetsToCache() {
  const networks = Object.values(await getEnabledNetworks());

  await Promise.all(
    networks.map(async (network) => {
      const assets = await getAssets(network.name, "aave");

      await db.assets.bulkUpsert(
        assets.map((a) => ({
          network_id: network.id,
          address: a.address,
          symbol: a.symbol,
          decimals: a.decimals,
        })),
      );

      await loadAssetsToCache(network.id);
    }),
  );
}

export async function loadAssetsToCache(network_id) {
  if (!network_id) return;
  const assets = await db.assets.findByNetwork(network_id);

  const assetsByAddress = Object.fromEntries(
    assets.map((a) => [
      a.address.toLowerCase(),
      {
        id: a.id,
        network_id: a.network_id,
        address: a.address,
        symbol: a.symbol,
        decimals: a.decimals,
      },
    ]),
  );
  await setAssetsToCache(network_id, assetsByAddress);
  console.log(
    `✅ Cached assets for network ${network_id}:`,
    Object.values(assetsByAddress).length,
  );
}

export async function getAssetsByNetwork(network_id) {
  return await getAssetsByNetworkCache(network_id);
}

export async function getAddressAssetsByNetwork(network_id) {
  const assets = await getAssetsByNetworkCache(network_id);
  const assetsArray = Object.values(assets);

  return Object.fromEntries(
    assetsArray.map((a) => [a.address.toLowerCase(), a]),
  );
}

export async function getAssetsByNetworks() {
  const networks = Object.values(await getEnabledNetworks());

  const results = await Promise.all(
    networks.map(async (network) => ({
      name: network.name,
      assets: await getAssetsByNetworkCache(network.id),
    })),
  );
  return Object.fromEntries(results.map(({ name, assets }) => [name, assets]));
}

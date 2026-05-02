//src/services/price.service.js
import { getPriceCache, setPriceToCache } from "../../cache/price.cache.js";
import { db } from "../../db/index.js";
import { getAddressAssetsByNetwork } from "../asset/asset.service.js";
import { getEnabledNetworks } from "../network/network.service.js";
import { getPrices } from "../../blockchain/index.js";

export async function syncPrices() {
  const alertPrice = new Map();
  const networks = await getEnabledNetworks();
  for (const network of Object.values(networks)) {
    console.log(`Price 🔗${network.name} `, network.id);
    const lastPrices = await loadCurrentOnchainPricesToCacheByNetwork(
      network.id,
    );
    const assets = await getAddressAssetsByNetwork(network.id);
    const prices = await getPrices(network.name, "aave", Object.values(assets));

    for (const price of Object.values(prices)) {
      const asset = assets[price.address.toLowerCase()];
      if (!asset?.address) {
        console.warn(
          "⚠️ asset.address is missing price.address:",
          price.address,
        );
        continue;
      }
      const change = diffPercent(lastPrices[price.address], price.price);
      if (change > 5) {
        let priceAddress = alertPrice.get(network);
        if (!priceAddress) {
          priceAddress = new Map();
        }
        const change =
          ((price.price - lastPrices[price.address].price_usd) /
            lastPrices[price.address].price_usd) *
          100;
        priceAddress.set(price.address, {
          asset,
          lastPrice: lastPrices[price.address],
          newPrice: price.price,
          change,
        });
        alertPrice.set(network, priceAddress);
      }
      await savePriceIfChanged(network, asset, price);
    }
  }
  return alertPrice;
}

function diffPercent(oldPrice, newPrice) {
  if (!oldPrice || oldPrice.price_usd === 0) return 0;

  return Math.abs((newPrice - oldPrice.price_usd) / oldPrice.price_usd) * 100;
}

export async function loadLastPricesToCache() {
  const networks = Object.values(await getEnabledNetworks());
  for (const network of networks) {
    await loadCurrentOnchainPricesToCacheByNetwork(network.id);
  }
}

export async function loadCurrentOnchainPricesToCacheByNetwork(network_id) {
  if (!network_id) return {};

  const pricesDb =
    await db.currentOnchainPrices.getLastPricesByNetwork(network_id);
  const prices = {};

  for (const price of pricesDb) {
    prices[price.address.toLowerCase()] = {
      price_usd: Number(price.price_usd),
      symbol: price.symbol,
      collected_at: price.calculated_at,
    };
  }

  await setPriceToCache(network_id, prices);
  console.log(
    `✅ Cached price for network ${network_id}:`,
    Object.values(prices).length,
  );

  return prices;
}

function pricePayloadFromDbRow(row) {
  return {
    price_usd: Number(row.price_usd),
    symbol: row.symbol,
    collected_at: row.calculated_at,
  };
}

/**
 * Цена 1 токена в USD по адресу
 */
export async function getAssetPriceUSD(network_id, assetAddress) {
  const address = assetAddress.toLowerCase();
  const dataPrice = await getPriceCache(network_id, address);
  if (dataPrice && dataPrice.price_usd != 0) {
    return dataPrice.price_usd;
  }

  const row = await db.currentOnchainPrices.getByNetworkAndAddress(
    network_id,
    address,
  );
  if (row) {
    const recovered = pricePayloadFromDbRow(row);
    await setPriceToCache(network_id, { [address]: recovered });
    return recovered.price_usd;
  }
  return 0;
}

export async function getAssetPrice(network_id, assetAddress) {
  const address = assetAddress.toLowerCase();
  let dataPrice = await getPriceCache(network_id, address);
  if (dataPrice && dataPrice.price_usd != null) {
    return dataPrice;
  }

  const row = await db.currentOnchainPrices.getByNetworkAndAddress(
    network_id,
    address,
  );
  if (row) {
    const recovered = pricePayloadFromDbRow(row);
    await setPriceToCache(network_id, { [address]: recovered });
    return recovered;
  }
  return null;
}

/*
 * Сохраняем цену токена по адресу (если изменилась)
 */
export async function savePriceIfChanged(network, asset, price) {
  if (!asset?.address || !asset?.id) {
    return;
  }

  const address = asset.address.toLowerCase();
  const dataPrice = await getPriceCache(network.id, address);
  const lastPrice =
    dataPrice && typeof dataPrice === "object" ? dataPrice.price_usd : undefined;

  const isChanged =
    lastPrice === undefined || Math.abs(lastPrice - price.price) >= 1e-8;

  try {
    if (isChanged) {
      await db.onchainPrices.create({
        network_id: network.id,
        asset_id: asset.id,
        price_usd: price.price,
        collected_at: price.collected_at,
      });
    }

    await db.currentOnchainPrices.upsert({
      network_id: network.id,
      asset_id: asset.id,
      price_usd: price.price,
      calculated_at: price.collected_at,
    });
  } catch (e) {
    console.error(
      `❌ Failed to save price for ${asset.id}:`,
      new Date().toISOString(),
      e,
    );
  }
}

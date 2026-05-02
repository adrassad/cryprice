import { getAsset } from "../asset/asset.service.js";
import { getEnabledNetworks } from "../network/network.service.js";
import { getAssetPrice } from "./price.service.js";

/**
 * On-chain current prices by ticker across enabled networks.
 * Returns one entry per enabled network (keys sorted by network name).
 * Value is the cached price payload or null if the asset is missing or has no cached price.
 */
export async function getCurrentOnchainPricesByTicker(symbol) {
  const priceByNetwork = {};
  const sorted = Object.values(await getEnabledNetworks()).sort((a, b) =>
    String(a.name).localeCompare(String(b.name)),
  );

  for (const network of sorted) {
    const asset = await getAsset(network.id, symbol);
    if (!asset) {
      priceByNetwork[network.name] = null;
      continue;
    }

    const price = await getAssetPrice(network.id, asset.address);
    priceByNetwork[network.name] = price ?? null;
  }

  return priceByNetwork;
}

import { db } from "../../db/index.js";
import {
  setNetworksToCashe,
  getEnabledNetworksCache,
} from "../../cache/network.cashe.js";

export async function getEnabledNetworks() {
  const cached = await getEnabledNetworksCache();
  if (!cached || Object.keys(cached).length === 0) {
    const networks = await getEnabledNetworksFromDB();
    await setNetworksToCashe(networks);
    return networks;
  }
  return cached;
}

export async function getNetwork(networkId) {
  const cached = await getEnabledNetworksCache();
  if (!cached || !cached[networkId]) {
    return db.networks.findById(networkId);
  }
  return cached[networkId];
}

export async function createNetworks(networks) {
  for (const network of networks) {
    await db.networks.create(network);
  }
}

export async function loadNetworksToCache() {
  const networks = await getEnabledNetworksFromDB();
  await setNetworksToCashe(networks);
}

export async function getEnabledNetworksFromDB() {
  const networks = await db.networks.findAll();
  const mapNetworks = {};
  for (const network of networks) {
    mapNetworks[network.id] = {
      id: network.id,
      chain_id: network.chain_id,
      name: network.name.toLowerCase(),
      native_symbol: network.native_symbol,
      enabled: network.enabled,
    };
  }
  return mapNetworks;
}

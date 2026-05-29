import { db } from "../../db/index.js";
import {
  setNetworksToCashe,
  getEnabledNetworksCache,
} from "../../cache/network.cashe.js";
import { resolveNativeLogoUrl } from "../asset/tokenIcon.service.js";

async function mapEnabledNetworkRow(network) {
  return {
    id: network.id,
    chain_id: network.chain_id,
    name: network.name.toLowerCase(),
    native_symbol: network.native_symbol,
    enabled: network.enabled,
    native_logo_url: await resolveNativeLogoUrl(network.chain_id),
  };
}

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
  const networks = await db.networks.findAll({ limit: 1000 });
  const enabledNetworks = networks.filter((network) => network.enabled);
  const mapped = await Promise.all(enabledNetworks.map(mapEnabledNetworkRow));
  const mapNetworks = {};

  for (const network of mapped) {
    mapNetworks[network.id] = network;
  }

  return mapNetworks;
}

// blockchain/networks/avalanche/index.js
import { createNetworkProvider } from "../../../config/rpc.config.js";

export function createAvalancheNetwork(config) {
  return {
    name: "avalanche",
    chainId: config.CHAIN_ID,
    provider: createNetworkProvider(config.RPC_URLS, {
      chainId: config.CHAIN_ID,
      networkName: "avalanche",
    }),
    config: {
      protocols: config.protocols,
    },
  };
}

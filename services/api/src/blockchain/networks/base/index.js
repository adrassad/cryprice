// blockchain/networks/base/index.js
import { createNetworkProvider } from "../../../config/rpc.config.js";

export function createBaseNetwork(config) {
  return {
    name: "base",
    chainId: config.CHAIN_ID,
    provider: createNetworkProvider(config.RPC_URLS, {
      chainId: config.CHAIN_ID,
      networkName: "base",
    }),
    config: {
      protocols: config.protocols,
    },
  };
}

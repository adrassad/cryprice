// blockchain/networks/arbitrum/index.js
import { createNetworkProvider } from "../../../config/rpc.config.js";

export function createArbitrumNetwork(config) {
  return {
    name: "arbitrum",
    chainId: config.CHAIN_ID,
    provider: createNetworkProvider(config.RPC_URLS, {
      chainId: config.CHAIN_ID,
      networkName: "arbitrum",
    }),
    config: {
      protocols: config.protocols,
    },
  };
}

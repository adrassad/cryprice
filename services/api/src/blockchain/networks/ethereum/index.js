// blockchain/networks/ethereum/index.js
import { createNetworkProvider } from "../../../config/rpc.config.js";

export function createEthereumNetwork(config) {
  return {
    name: "ethereum",
    chainId: config.CHAIN_ID,
    provider: createNetworkProvider(config.RPC_URLS, {
      chainId: config.CHAIN_ID,
      networkName: "ethereum",
    }),
    config: {
      protocols: config.protocols,
    },
  };
}

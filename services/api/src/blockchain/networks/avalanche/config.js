// src/blockchain/networks/avalanche/config.js
import { networksConfig } from "../../../config/networks.config.js";

export const NETWORK_CONFIG = {
  name: "avalanche",
  chainId: networksConfig.avalanche.CHAIN_ID,
  RPC_URL: networksConfig.avalanche.RPC_URL,

  // Aave
  aave: {
    ADDRESSES_PROVIDER:
      networksConfig.avalanche.protocols.aave.ADDRESSES_PROVIDER,
  },
};

// src/blockchain/networks/arbitrum/config.js
import { networksConfig } from "../../../config/networks.config.js";

export const NETWORK_CONFIG = {
  name: "arbitrum",
  chainId: 42161,
  RPC_URL: networksConfig.arbitrum.RPC_URL,

  // Aave
  aave: {
    ADDRESSES_PROVIDER:
      networksConfig.arbitrum.protocols.aave.ADDRESSES_PROVIDER,
  },
};

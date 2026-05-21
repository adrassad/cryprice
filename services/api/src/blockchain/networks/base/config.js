// src/blockchain/networks/arbitrum/config.js
import { networksConfig } from "../../../config/networks.config.js";

export const NETWORK_CONFIG = {
  name: "base",
  chainId: 8453,
  RPC_URL: networksConfig.base.RPC_URL,

  // Aave
  aave: {
    ADDRESSES_PROVIDER: networksConfig.base.protocols.aave.ADDRESSES_PROVIDER,
  },
};

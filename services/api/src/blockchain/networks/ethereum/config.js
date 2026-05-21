// src/blockchain/networks/ethereum/config.js
import { networksConfig } from "../../../config/networks.config.js";

export const NETWORK_CONFIG = {
  name: "ethereum",
  chainId: 1,
  RPC_URL: networksConfig.ethereum.RPC_URL,

  // Aave
  aave: {
    ADDRESSES_PROVIDER:
      networksConfig.ethereum.protocols.aave.ADDRESSES_PROVIDER,
  },
};

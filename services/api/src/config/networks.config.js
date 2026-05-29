// src/config/networks.config.js
import { applyRpcEnvToNetwork } from "./rpc.config.js";

const baseNetworksConfig = {
  ethereum: {
    CHAIN_ID: 1,
    name: "ethereum",
    NATIVE_SYMBOL: "ETH",
    ENABLED: true,
    explorer: {
      url: process.env.ETHEREUM_EXPLORER,
      apiKey: process.env.ETHEREUM_EXPLORER_KEY,
      type: "v2",
    },
    protocols: {
      aave: {
        ADDRESSES_PROVIDER: process.env.ETHEREUM_AAVE_ADDRESSES_PROVIDER,
        DATA_PROVIDER: process.env.ETHEREUM_AAVE_POOL_DATA_PROVIDER,
      },
    },
  },

  arbitrum: {
    CHAIN_ID: 42161,
    name: "arbitrum",
    NATIVE_SYMBOL: "ETH",
    ENABLED: true,
    explorer: {
      url: process.env.ARBITRUM_EXPLORER,
      apiKey: process.env.ARBITRUM_EXPLORER_KEY,
      type: "v2",
    },
    protocols: {
      aave: {
        ADDRESSES_PROVIDER: process.env.ARBITRUM_AAVE_ADDRESSES_PROVIDER,
        DATA_PROVIDER: process.env.ARBITRUM_AAVE_POOL_DATA_PROVIDER,
      },
    },
  },

  avalanche: {
    CHAIN_ID: 43114,
    name: "avalanche",
    NATIVE_SYMBOL: "AVAX",
    ENABLED: true,
    explorer: {
      url: process.env.AVALANCHE_EXPLORER,
      apiKey: process.env.AVALANCHE_EXPLORER_KEY,
      type: "snowtrace",
    },
    protocols: {
      aave: {
        ADDRESSES_PROVIDER: process.env.AVALANCHE_AAVE_ADDRESSES_PROVIDER,
        DATA_PROVIDER: process.env.AVALANCHE_AAVE_POOL_DATA_PROVIDER,
      },
    },
  },

  base: {
    CHAIN_ID: 8453,
    name: "base",
    NATIVE_SYMBOL: "ETH",
    ENABLED: true,
    explorer: {
      url: process.env.BASE_EXPLORER,
      apiKey: process.env.BASE_EXPLORER_KEY,
      type: "v2",
    },
    protocols: {
      aave: {
        ADDRESSES_PROVIDER: process.env.BASE_AAVE_ADDRESSES_PROVIDER,
        DATA_PROVIDER: process.env.BASE_AAVE_POOL_DATA_PROVIDER,
      },
    },
  },
};

const RPC_ENV_BY_NETWORK = {
  ethereum: {
    primaryUrl: process.env.ETHEREUM_RPC_URL,
    urlsList: process.env.ETHEREUM_RPC_URLS,
  },
  arbitrum: {
    primaryUrl: process.env.ARBITRUM_RPC_URL,
    urlsList: process.env.ARBITRUM_RPC_URLS,
  },
  avalanche: {
    primaryUrl: process.env.AVALANCHE_RPC_URL,
    urlsList: process.env.AVALANCHE_RPC_URLS,
  },
  base: {
    primaryUrl: process.env.BASE_RPC_URL,
    urlsList: process.env.BASE_RPC_URLS,
  },
};

export const networksConfig = Object.fromEntries(
  Object.entries(baseNetworksConfig).map(([key, network]) => [
    key,
    applyRpcEnvToNetwork(network, RPC_ENV_BY_NETWORK[key]),
  ]),
);

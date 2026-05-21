// src/config/networks.config.js
export const networksConfig = {
  ethereum: {
    CHAIN_ID: 1,
    name: "ethereum",
    NATIVE_SYMBOL: "ETH",
    ENABLED: true,
    RPC_URL: process.env.ETHEREUM_RPC_URL,
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
    RPC_URL: process.env.ARBITRUM_RPC_URL,
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
    RPC_URL: process.env.AVALANCHE_RPC_URL,
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
    RPC_URL: process.env.BASE_RPC_URL,
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

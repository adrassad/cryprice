/**
 * Env defaults for HTTP subprocess helpers that import createApp
 * (networks.config requires RPC URLs at module load).
 */
export function withHttpTestEnv(extra = {}) {
  return {
    ...process.env,
    PATH: process.env.PATH ?? "",
    NODE_ENV: process.env.NODE_ENV || "development",
    DATABASE_URL:
      process.env.DATABASE_URL ||
      "postgres://test:test@localhost:5432/cryprice_test",
    BOT_TOKEN: process.env.BOT_TOKEN || "test-token-for-ci",
    ETHEREUM_RPC_URL:
      process.env.ETHEREUM_RPC_URL || "https://ethereum-rpc.publicnode.com",
    ARBITRUM_RPC_URL:
      process.env.ARBITRUM_RPC_URL || "https://arb1.arbitrum.io/rpc",
    AVALANCHE_RPC_URL:
      process.env.AVALANCHE_RPC_URL ||
      "https://api.avax.network/ext/bc/C/rpc",
    BASE_RPC_URL: process.env.BASE_RPC_URL || "https://mainnet.base.org",
    ...extra,
  };
}

import { postgresClient } from "./connection.js";
import { prepareOffchainSchemaBeforeInitDdl } from "./migrateOffchainPricesSchema.js";
import { migrateUserAuthSchemaIfNeeded } from "./migrateUserAuthSchema.js";
import { migrateUserInternalIdPhase1IfNeeded } from "./migrateUserInternalIdPhase1.js";

export async function initDb() {
  //
  // USERS
  //
  await postgresClient.query(`
  CREATE TABLE IF NOT EXISTS users (
    telegram_id BIGINT PRIMARY KEY,
    username TEXT,
    first_name TEXT,
    last_name TEXT,
    language TEXT,
    subscription_level TEXT NOT NULL DEFAULT 'free',
    subscription_end TIMESTAMPTZ,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    threshold_hf NUMERIC(10, 2) DEFAULT 1.2,
    email TEXT,
    email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
  );
`);

  await postgresClient.query(`
    CREATE OR REPLACE FUNCTION update_updated_at_column()
    RETURNS TRIGGER AS $$
    BEGIN
      IF NEW IS DISTINCT FROM OLD THEN
        NEW.updated_at = NOW();
      END IF;
      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
  `);

  await postgresClient.query(`
    DROP TRIGGER IF EXISTS trg_users_updated_at ON users;
  `);

  await postgresClient.query(`
    CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
  `);

  //
  // WALLETS
  //
  await postgresClient.query(`
    CREATE TABLE IF NOT EXISTS wallets (
      id BIGSERIAL PRIMARY KEY,
      user_id BIGINT NOT NULL
        REFERENCES users(telegram_id)
        ON DELETE CASCADE,
      address TEXT NOT NULL,
      label TEXT,
      created_at TIMESTAMPTZ DEFAULT NOW(),

      CONSTRAINT wallets_user_address_unique
        UNIQUE (user_id, address)
    );
  `);

  await postgresClient.query(`
    CREATE INDEX IF NOT EXISTS idx_wallets_user_id
    ON wallets(user_id);
  `);

  await postgresClient.query(`
    CREATE INDEX IF NOT EXISTS idx_wallets_address
    ON wallets(address);
  `);

  //
  // NETWORKS
  //
  await postgresClient.query(`
    CREATE TABLE IF NOT EXISTS networks (
      id SERIAL PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      chain_id INTEGER NOT NULL UNIQUE,
      native_symbol TEXT NOT NULL,
      enabled BOOLEAN NOT NULL DEFAULT TRUE,
      created_at TIMESTAMPTZ DEFAULT NOW()
    );
  `);

  //
  // ASSETS
  //
  await postgresClient.query(`
    CREATE TABLE IF NOT EXISTS assets (
      id BIGSERIAL PRIMARY KEY,

      network_id INTEGER NOT NULL
        REFERENCES networks(id)
        ON DELETE CASCADE,

      address TEXT NOT NULL,

      symbol TEXT NOT NULL,

      decimals INTEGER NOT NULL,

      CONSTRAINT assets_network_address_unique
        UNIQUE (network_id, address)
    );
  `);

  await postgresClient.query(`
    CREATE INDEX IF NOT EXISTS idx_assets_network
    ON assets(network_id);
  `);

  await postgresClient.query(`
    CREATE INDEX IF NOT EXISTS idx_assets_symbol
    ON assets(symbol);
  `);

  await postgresClient.query(`
    CREATE INDEX IF NOT EXISTS idx_assets_address
    ON assets(address);
  `);

  /**
   * Must run before off-chain CREATE INDEX on `token`/`pair`.
   * `CREATE TABLE IF NOT EXISTS` does not upgrade legacy offchain_prices rows still on `asset_id`;
   * indexes referencing `token` would then fail with "column token does not exist".
   */
  await prepareOffchainSchemaBeforeInitDdl(postgresClient);

  //
  //PRICES TABLES
  //
  await postgresClient.query(`
    BEGIN;

    CREATE TABLE IF NOT EXISTS onchain_prices (
      id BIGSERIAL PRIMARY KEY,
      network_id INTEGER NOT NULL REFERENCES networks(id) ON DELETE CASCADE,
      asset_id INTEGER NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
      price_usd NUMERIC(38,18) NOT NULL CHECK (price_usd >= 0),
      collected_at TIMESTAMPTZ NOT NULL,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    CREATE UNIQUE INDEX IF NOT EXISTS ux_onchain_prices_unique_point
    ON onchain_prices(network_id, asset_id, collected_at);

    CREATE TABLE IF NOT EXISTS current_onchain_prices (
      network_id INTEGER NOT NULL REFERENCES networks(id) ON DELETE CASCADE,
      asset_id INTEGER NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
      price_usd NUMERIC(38,18) NOT NULL CHECK (price_usd >= 0),
      calculated_at TIMESTAMPTZ NOT NULL,
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      PRIMARY KEY (network_id, asset_id)
    );

    CREATE TABLE IF NOT EXISTS offchain_prices (
      id BIGSERIAL PRIMARY KEY,
      source VARCHAR(20) NOT NULL,
      token TEXT NOT NULL,
      pair TEXT NOT NULL,
      price_usd NUMERIC(38,18) NOT NULL CHECK (price_usd >= 0),
      collected_at TIMESTAMPTZ NOT NULL,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      CHECK (source IN ('binance', 'bybit', 'coingecko'))
    );

    CREATE UNIQUE INDEX IF NOT EXISTS ux_offchain_prices_unique_point
    ON offchain_prices(source, pair, collected_at);

    CREATE INDEX IF NOT EXISTS idx_offchain_prices_token_lookup
    ON offchain_prices(token, collected_at DESC);

    CREATE TABLE IF NOT EXISTS current_offchain_prices (
      source VARCHAR(20) NOT NULL,
      token TEXT NOT NULL,
      pair TEXT NOT NULL,
      price_usd NUMERIC(38,18) NOT NULL CHECK (price_usd >= 0),
      calculated_at TIMESTAMPTZ NOT NULL,
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      PRIMARY KEY (source, pair),
      CHECK (source IN ('binance', 'bybit', 'coingecko'))
    );

    CREATE INDEX IF NOT EXISTS idx_current_offchain_prices_token
    ON current_offchain_prices(token);

    COMMIT;
  `);

  //
  // HEALTHFACTORS
  //
  await postgresClient.query(`
    CREATE TABLE IF NOT EXISTS healthfactors (
      id BIGSERIAL PRIMARY KEY,
      address TEXT NOT NULL,
      protocol TEXT NOT NULL,
      network_id INTEGER NOT NULL
        REFERENCES networks(id)
        ON DELETE CASCADE,
      healthfactor DOUBLE PRECISION NOT NULL,
      collected_at TIMESTAMPTZ NOT NULL,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
  `);

  await postgresClient.query(`
    CREATE INDEX IF NOT EXISTS idx_hf_lookup
    ON healthfactors(address, protocol, network_id, created_at DESC);
  `);

  await postgresClient.query(`
    CREATE UNIQUE INDEX IF NOT EXISTS uniq_hf_exact
    ON healthfactors(address, protocol, network_id, created_at);
  `);

  await migrateUserAuthSchemaIfNeeded(postgresClient);
  await migrateUserInternalIdPhase1IfNeeded(postgresClient);

  console.log("✅ DB initialized");
}

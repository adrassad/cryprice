/**
 * Idempotent migration: auth tables, users profile columns, sequence for API-only telegram_id surrogates.
 * Real Telegram user ids are positive; Google-only users get negative ids from users_api_telegram_id_seq.
 */
export async function migrateUserAuthSchemaIfNeeded(db) {
  await db.query(`
    CREATE SEQUENCE IF NOT EXISTS users_api_telegram_id_seq
      AS BIGINT
      INCREMENT BY -1
      START WITH -1000000001
      MINVALUE -9223372036854775808
      MAXVALUE -1000000000
  `);

  await db.query(`
    ALTER TABLE users ADD COLUMN IF NOT EXISTS email TEXT
  `);
  await db.query(`
    ALTER TABLE users ADD COLUMN IF NOT EXISTS email_verified BOOLEAN NOT NULL DEFAULT FALSE
  `);
  await db.query(`
    ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_url TEXT
  `);

  await db.query(`
    CREATE TABLE IF NOT EXISTS auth_identities (
      id BIGSERIAL PRIMARY KEY,
      provider TEXT NOT NULL CHECK (provider IN ('google')),
      provider_user_id TEXT NOT NULL,
      user_telegram_id BIGINT NOT NULL
        REFERENCES users(telegram_id) ON DELETE CASCADE,
      email TEXT,
      email_verified BOOLEAN NOT NULL DEFAULT FALSE,
      avatar_url TEXT,
      profile_json JSONB,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      UNIQUE (provider, provider_user_id)
    )
  `);
  await db.query(`
    CREATE INDEX IF NOT EXISTS idx_auth_identities_user
    ON auth_identities(user_telegram_id)
  `);

  await db.query(`
    CREATE TABLE IF NOT EXISTS refresh_tokens (
      id BIGSERIAL PRIMARY KEY,
      user_telegram_id BIGINT NOT NULL
        REFERENCES users(telegram_id) ON DELETE CASCADE,
      token_hash TEXT NOT NULL UNIQUE,
      expires_at TIMESTAMPTZ NOT NULL,
      revoked_at TIMESTAMPTZ,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    )
  `);
  await db.query(`
    CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user
    ON refresh_tokens(user_telegram_id)
  `);
  await db.query(`
    CREATE INDEX IF NOT EXISTS idx_refresh_tokens_expires
    ON refresh_tokens(expires_at)
    WHERE revoked_at IS NULL
  `);
}

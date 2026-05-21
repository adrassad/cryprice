/**
 * Account linking tokens for authenticated Google → Telegram linking flow.
 */
export async function migrateAccountLinkTokensIfNeeded(db) {
  await db.query(`
    CREATE TABLE IF NOT EXISTS account_link_tokens (
      id BIGSERIAL PRIMARY KEY,
      token_hash TEXT NOT NULL UNIQUE,
      user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      provider TEXT NOT NULL,
      purpose TEXT NOT NULL DEFAULT 'link',
      expires_at TIMESTAMPTZ NOT NULL,
      used_at TIMESTAMPTZ,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    )
  `);
  await db.query(`
    CREATE INDEX IF NOT EXISTS idx_account_link_tokens_user_id
    ON account_link_tokens(user_id)
  `);
  await db.query(`
    CREATE INDEX IF NOT EXISTS idx_account_link_tokens_expires
    ON account_link_tokens(expires_at)
    WHERE used_at IS NULL
  `);
}

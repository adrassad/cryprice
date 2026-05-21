/**
 * Phase 1 (additive): internal user id on `users`, parallel `user_id` on auth tables.
 *
 * - Adds `users.id` (BIGSERIAL semantics), backfills, UNIQUE NOT NULL.
 * - Keeps `users.telegram_id` as PRIMARY KEY; no JWT / API shape changes here.
 * - Adds nullable `user_id` → `users.id` on `auth_identities` and `refresh_tokens`, backfills.
 *
 * PHASE 2+ (not this file): drop synthetic negative `telegram_id` for Google-only users,
 * repoint FKs from `user_telegram_id` to `user_id`, migrate JWT `sub` to `users.id`.
 * Do not null out `telegram_id` for those rows until dependents are migrated.
 *
 * `users_api_telegram_id_seq` remains in use until Phase 2+.
 */
export async function migrateUserInternalIdPhase1IfNeeded(db) {
  await db.query(`
    CREATE SEQUENCE IF NOT EXISTS users_id_seq AS BIGINT
  `);

  await db.query(`
    ALTER TABLE users ADD COLUMN IF NOT EXISTS id BIGINT
  `);

  await db.query(`
    UPDATE users SET id = nextval('users_id_seq') WHERE id IS NULL
  `);

  await db.query(`
    SELECT setval(
      'users_id_seq',
      GREATEST((SELECT COALESCE(MAX(id), 1) FROM users), 1),
      (SELECT EXISTS(SELECT 1 FROM users))
    )
  `);

  await db.query(`
    ALTER TABLE users ALTER COLUMN id SET DEFAULT nextval('users_id_seq')
  `);

  await db.query(`
    ALTER SEQUENCE users_id_seq OWNED BY users.id
  `);

  await db.query(`
    ALTER TABLE users ALTER COLUMN id SET NOT NULL
  `);

  await db.query(`
    CREATE UNIQUE INDEX IF NOT EXISTS ux_users_internal_id ON users (id)
  `);

  await db.query(`
    ALTER TABLE auth_identities ADD COLUMN IF NOT EXISTS user_id BIGINT
  `);

  await db.query(`
    UPDATE auth_identities AS a
    SET user_id = u.id
    FROM users AS u
    WHERE a.user_telegram_id = u.telegram_id
      AND (a.user_id IS NULL OR a.user_id IS DISTINCT FROM u.id)
  `);

  await db.query(`
    CREATE INDEX IF NOT EXISTS idx_auth_identities_user_id
    ON auth_identities (user_id)
  `);

  await db.query(`
    DO $$
    BEGIN
      IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'auth_identities_user_id_fkey'
      ) THEN
        ALTER TABLE auth_identities
          ADD CONSTRAINT auth_identities_user_id_fkey
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE;
      END IF;
    END
    $$;
  `);

  await db.query(`
    ALTER TABLE refresh_tokens ADD COLUMN IF NOT EXISTS user_id BIGINT
  `);

  await db.query(`
    UPDATE refresh_tokens AS r
    SET user_id = u.id
    FROM users AS u
    WHERE r.user_telegram_id = u.telegram_id
      AND (r.user_id IS NULL OR r.user_id IS DISTINCT FROM u.id)
  `);

  await db.query(`
    CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id
    ON refresh_tokens (user_id)
  `);

  await db.query(`
    DO $$
    BEGIN
      IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'refresh_tokens_user_id_fkey'
      ) THEN
        ALTER TABLE refresh_tokens
          ADD CONSTRAINT refresh_tokens_user_id_fkey
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE;
      END IF;
    END
    $$;
  `);
}

/**
 * Post-migration checks for scripts and tests. Does not modify data.
 * @returns {{ ok: boolean, errors: string[] }}
 */
export async function verifyUserInternalIdPhase1(db) {
  const errors = [];

  const nullUserId = await db.query(
    `SELECT COUNT(*)::int AS n FROM users WHERE id IS NULL`,
  );
  if (nullUserId.rows[0]?.n > 0) {
    errors.push(`users.id: expected 0 NULL ids, got ${nullUserId.rows[0].n}`);
  }

  const dupIds = await db.query(
    `
    SELECT id, COUNT(*)::int AS c
    FROM users
    GROUP BY id
    HAVING COUNT(*) > 1
    `,
  );
  if (dupIds.rows.length > 0) {
    errors.push(`users.id: duplicate internal ids: ${dupIds.rows.length} value(s)`);
  }

  const orphanAuth = await db.query(
    `
    SELECT COUNT(*)::int AS n
    FROM auth_identities a
    WHERE a.user_id IS NULL
      AND EXISTS (SELECT 1 FROM users u WHERE u.telegram_id = a.user_telegram_id)
    `,
  );
  if (orphanAuth.rows[0]?.n > 0) {
    errors.push(
      `auth_identities.user_id: ${orphanAuth.rows[0].n} row(s) still NULL but user exists`,
    );
  }

  const orphanRefresh = await db.query(
    `
    SELECT COUNT(*)::int AS n
    FROM refresh_tokens r
    WHERE r.user_id IS NULL
      AND EXISTS (SELECT 1 FROM users u WHERE u.telegram_id = r.user_telegram_id)
    `,
  );
  if (orphanRefresh.rows[0]?.n > 0) {
    errors.push(
      `refresh_tokens.user_id: ${orphanRefresh.rows[0].n} row(s) still NULL but user exists`,
    );
  }

  return { ok: errors.length === 0, errors };
}

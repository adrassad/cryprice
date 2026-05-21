/**
 * Idempotent migration: token icon metadata columns on assets.
 *
 * Adds logo_status, logo_source, logo_local_path, logo_updated_at,
 * logo_content_hash, and logo_error for locally cached/generated icons.
 * Safe to run on every startup; does not modify existing asset rows.
 */
async function tableExists(db, tableName) {
  const { rows } = await db.query(
    `
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = $1
    `,
    [tableName],
  );
  return rows.length > 0;
}

export async function migrateAssetTokenIconsSchemaIfNeeded(db) {
  if (!(await tableExists(db, "assets"))) return;

  console.log(
    "⏱ Migrating assets token icon metadata...",
    new Date().toISOString(),
  );

  await db.query(`
    ALTER TABLE assets
      ADD COLUMN IF NOT EXISTS logo_status TEXT NOT NULL DEFAULT 'pending'
  `);
  await db.query(`
    ALTER TABLE assets
      ADD COLUMN IF NOT EXISTS logo_source TEXT NULL
  `);
  await db.query(`
    ALTER TABLE assets
      ADD COLUMN IF NOT EXISTS logo_local_path TEXT NULL
  `);
  await db.query(`
    ALTER TABLE assets
      ADD COLUMN IF NOT EXISTS logo_updated_at TIMESTAMPTZ NULL
  `);
  await db.query(`
    ALTER TABLE assets
      ADD COLUMN IF NOT EXISTS logo_content_hash TEXT NULL
  `);
  await db.query(`
    ALTER TABLE assets
      ADD COLUMN IF NOT EXISTS logo_error TEXT NULL
  `);

  await db.query(`
    DO $$
    BEGIN
      IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'assets_logo_status_check'
          AND conrelid = 'public.assets'::regclass
      ) THEN
        ALTER TABLE public.assets
          ADD CONSTRAINT assets_logo_status_check
          CHECK (logo_status IN ('pending', 'ready', 'failed', 'skipped'));
      END IF;

      IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'assets_logo_source_check'
          AND conrelid = 'public.assets'::regclass
      ) THEN
        ALTER TABLE public.assets
          ADD CONSTRAINT assets_logo_source_check
          CHECK (
            logo_source IS NULL
            OR logo_source IN ('generated', 'manual', 'trust_wallet', 'token_list')
          );
      END IF;
    END
    $$;
  `);

  await db.query(`
    CREATE INDEX IF NOT EXISTS idx_assets_logo_status
    ON assets(logo_status)
  `);

  console.log(
    "✅ Assets token icon metadata migration complete",
    new Date().toISOString(),
  );
}

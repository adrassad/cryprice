/**
 * Off-chain price schema evolution (run before CREATE INDEX/DDL that references columns).
 *
 * 1) Legacy: asset_id → token (join assets.symbol).
 * 2) Add `pair`: provider instrument id (e.g. BTCUSDT, or CoinGecko coin id). PK/UNIQUE use `pair`.
 *
 * prepareOffchainSchemaBeforeInitDdl must run after `assets` exists and *before* the PRICES
 * transaction that creates indexes on `token` / `pair`, so existing DBs with old column sets
 * are migrated first (CREATE TABLE IF NOT EXISTS does not upgrade old tables).
 */
async function tableExists(db, name) {
  const { rows } = await db.query(
    `
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = $1
    `,
    [name],
  );
  return rows.length > 0;
}

async function columnExists(db, tableName, columnName) {
  const { rows } = await db.query(
    `
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = $1
      AND column_name = $2
    `,
    [tableName, columnName],
  );
  return rows.length > 0;
}

export async function migrateLegacyOffchainAssetIdToTokenIfNeeded(db) {
  const hasAssetId = await columnExists(db, "offchain_prices", "asset_id");
  if (!hasAssetId) return;

  console.log(
    "⏱ Migrating offchain_prices / current_offchain_prices from asset_id to token...",
    new Date().toISOString(),
  );

  await db.query(
    `ALTER TABLE offchain_prices ADD COLUMN IF NOT EXISTS token TEXT`,
  );
  await db.query(`
    UPDATE offchain_prices p
    SET token = UPPER(TRIM(a.symbol))
    FROM assets a
    WHERE p.asset_id = a.id
      AND (p.token IS NULL OR btrim(p.token) = '')
  `);
  await db.query(`
    DELETE FROM offchain_prices WHERE token IS NULL OR btrim(token) = ''
  `);

  await db.query(`DROP INDEX IF EXISTS ux_offchain_prices_unique_point`);
  await db.query(`DROP INDEX IF EXISTS idx_offchain_prices_lookup`);
  await db.query(`ALTER TABLE offchain_prices DROP COLUMN IF EXISTS asset_id CASCADE`);

  await db.query(`ALTER TABLE offchain_prices ALTER COLUMN token SET NOT NULL`);

  await db.query(`
    DELETE FROM offchain_prices a
    USING offchain_prices b
    WHERE a.id > b.id
      AND a.source = b.source
      AND a.token = b.token
      AND a.collected_at = b.collected_at
  `);

  await db.query(`
    CREATE UNIQUE INDEX IF NOT EXISTS ux_offchain_prices_unique_point
    ON offchain_prices (source, token, collected_at)
  `);
  await db.query(`
    CREATE INDEX IF NOT EXISTS idx_offchain_prices_token_lookup
    ON offchain_prices (token, collected_at DESC)
  `);

  await db.query(
    `ALTER TABLE current_offchain_prices ADD COLUMN IF NOT EXISTS token TEXT`,
  );
  await db.query(`
    UPDATE current_offchain_prices p
    SET token = UPPER(TRIM(a.symbol))
    FROM assets a
    WHERE p.asset_id = a.id
      AND (p.token IS NULL OR btrim(p.token) = '')
  `);
  await db.query(`
    DELETE FROM current_offchain_prices WHERE token IS NULL OR btrim(token) = ''
  `);

  await db.query(`
    DELETE FROM current_offchain_prices c
    WHERE c.ctid NOT IN (
      SELECT DISTINCT ON (p.source, p.token) p.ctid
      FROM current_offchain_prices p
      ORDER BY p.source, p.token, p.calculated_at DESC, p.updated_at DESC
    )
  `);

  await db.query(`DROP INDEX IF EXISTS idx_current_offchain_prices_asset`);
  await db.query(
    `ALTER TABLE current_offchain_prices DROP COLUMN IF EXISTS asset_id CASCADE`,
  );

  await db.query(
    `ALTER TABLE current_offchain_prices ALTER COLUMN token SET NOT NULL`,
  );

  await db.query(`
    DO $$
    BEGIN
      IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'current_offchain_prices_pkey'
          AND conrelid = 'current_offchain_prices'::regclass
      ) THEN
        ALTER TABLE current_offchain_prices
        ADD PRIMARY KEY (source, token);
      END IF;
    END $$;
  `);

  await db.query(`
    CREATE INDEX IF NOT EXISTS idx_current_offchain_prices_token
    ON current_offchain_prices (token)
  `);

  console.log(
    "✅ Offchain asset_id → token migration done",
    new Date().toISOString(),
  );
}

/**
 * Add provider `pair` key and switch uniqueness to (source, pair) so all spot instruments fit.
 */
export async function migrateOffchainAddPairColumnIfNeeded(db) {
  if (!(await tableExists(db, "offchain_prices"))) return;
  const hasPairOff = await columnExists(db, "offchain_prices", "pair");
  const hasPairCur = await columnExists(db, "current_offchain_prices", "pair");
  if (hasPairOff && hasPairCur) return;

  console.log(
    "⏱ Migrating offchain tables: adding pair column and PK (source, pair)...",
    new Date().toISOString(),
  );

  if (!hasPairOff) {
    await db.query(`ALTER TABLE offchain_prices ADD COLUMN pair TEXT`);
  }
  if (!hasPairCur) {
    await db.query(`ALTER TABLE current_offchain_prices ADD COLUMN pair TEXT`);
  }
  await db.query(`
    UPDATE offchain_prices SET pair = token WHERE pair IS NULL OR btrim(pair) = ''
  `);
  await db.query(`DELETE FROM offchain_prices WHERE pair IS NULL OR btrim(pair) = ''`);
  await db.query(`ALTER TABLE offchain_prices ALTER COLUMN pair SET NOT NULL`);

  await db.query(`DROP INDEX IF EXISTS ux_offchain_prices_unique_point`);
  await db.query(`
    DELETE FROM offchain_prices a
    USING offchain_prices b
    WHERE a.id > b.id
      AND a.source = b.source
      AND a.pair = b.pair
      AND a.collected_at = b.collected_at
  `);
  await db.query(`
    CREATE UNIQUE INDEX IF NOT EXISTS ux_offchain_prices_unique_point
    ON offchain_prices (source, pair, collected_at)
  `);
  await db.query(`
    CREATE INDEX IF NOT EXISTS idx_offchain_prices_token_lookup
    ON offchain_prices (token, collected_at DESC)
  `);

  await db.query(`
    UPDATE current_offchain_prices SET pair = token WHERE pair IS NULL OR btrim(pair) = ''
  `);
  await db.query(`
    DELETE FROM current_offchain_prices WHERE pair IS NULL OR btrim(pair) = ''
  `);

  await db.query(`
    DELETE FROM current_offchain_prices c
    WHERE c.ctid NOT IN (
      SELECT DISTINCT ON (p.source, p.pair) p.ctid
      FROM current_offchain_prices p
      ORDER BY p.source, p.pair, p.calculated_at DESC, p.updated_at DESC
    )
  `);

  await db.query(`ALTER TABLE current_offchain_prices ALTER COLUMN pair SET NOT NULL`);

  await db.query(
    `ALTER TABLE current_offchain_prices DROP CONSTRAINT IF EXISTS current_offchain_prices_pkey`,
  );
  await db.query(`
    ALTER TABLE current_offchain_prices
    ADD PRIMARY KEY (source, pair)
  `);

  await db.query(`DROP INDEX IF EXISTS idx_current_offchain_prices_token`);
  await db.query(`
    CREATE INDEX IF NOT EXISTS idx_current_offchain_prices_token
    ON current_offchain_prices (token)
  `);

  console.log(
    "✅ Offchain pair migration done",
    new Date().toISOString(),
  );
}

/**
 * Run after `assets` exists, before off-chain CREATE TABLE / indexes in initDb.
 */
export async function prepareOffchainSchemaBeforeInitDdl(db) {
  if (!(await tableExists(db, "offchain_prices"))) return;
  await migrateLegacyOffchainAssetIdToTokenIfNeeded(db);
  await migrateOffchainAddPairColumnIfNeeded(db);
}

/** @deprecated use prepareOffchainSchemaBeforeInitDdl at end of init for idempotent repair only */
export async function migrateOffchainPricesSchemaIfNeeded(db) {
  await prepareOffchainSchemaBeforeInitDdl(db);
}

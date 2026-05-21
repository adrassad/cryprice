/**
 * Align on-chain price asset ids with assets.id (BIGINT).
 *
 * Fresh databases get BIGINT from init.js. Existing databases may still have
 * INTEGER asset_id columns from earlier DDL, so this migration widens them
 * while preserving the current FK / PK / unique-index contract.
 */
export async function migrateOnchainPriceAssetIdBigintIfNeeded(db) {
  await db.query(`
    BEGIN;

    DO $$
    DECLARE
      r RECORD;
    BEGIN
      IF to_regclass('public.onchain_prices') IS NULL
        OR to_regclass('public.current_onchain_prices') IS NULL
      THEN
        RETURN;
      END IF;

      IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name IN ('onchain_prices', 'current_onchain_prices')
          AND column_name = 'asset_id'
          AND data_type = 'integer'
      ) THEN
        DROP INDEX IF EXISTS public.ux_onchain_prices_unique_point;

        ALTER TABLE public.current_onchain_prices
          DROP CONSTRAINT IF EXISTS current_onchain_prices_pkey;

        FOR r IN
          SELECT c.conrelid::regclass AS table_name, c.conname
          FROM pg_constraint c
          WHERE c.contype = 'f'
            AND c.conrelid IN (
              'public.onchain_prices'::regclass,
              'public.current_onchain_prices'::regclass
            )
            AND EXISTS (
              SELECT 1
              FROM unnest(c.conkey) AS k(attnum)
              JOIN pg_attribute a
                ON a.attrelid = c.conrelid
               AND a.attnum = k.attnum
              WHERE a.attname = 'asset_id'
            )
        LOOP
          EXECUTE format(
            'ALTER TABLE %s DROP CONSTRAINT %I',
            r.table_name,
            r.conname
          );
        END LOOP;

        ALTER TABLE public.onchain_prices
          ALTER COLUMN asset_id TYPE BIGINT USING asset_id::bigint;

        ALTER TABLE public.current_onchain_prices
          ALTER COLUMN asset_id TYPE BIGINT USING asset_id::bigint;
      END IF;

      IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'onchain_prices_asset_id_fkey'
          AND conrelid = 'public.onchain_prices'::regclass
      ) THEN
        ALTER TABLE public.onchain_prices
          ADD CONSTRAINT onchain_prices_asset_id_fkey
          FOREIGN KEY (asset_id) REFERENCES public.assets(id) ON DELETE CASCADE;
      END IF;

      IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'current_onchain_prices_asset_id_fkey'
          AND conrelid = 'public.current_onchain_prices'::regclass
      ) THEN
        ALTER TABLE public.current_onchain_prices
          ADD CONSTRAINT current_onchain_prices_asset_id_fkey
          FOREIGN KEY (asset_id) REFERENCES public.assets(id) ON DELETE CASCADE;
      END IF;

      IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'current_onchain_prices_pkey'
          AND conrelid = 'public.current_onchain_prices'::regclass
      ) THEN
        ALTER TABLE public.current_onchain_prices
          ADD CONSTRAINT current_onchain_prices_pkey
          PRIMARY KEY (network_id, asset_id);
      END IF;
    END
    $$;

    CREATE UNIQUE INDEX IF NOT EXISTS ux_onchain_prices_unique_point
      ON onchain_prices(network_id, asset_id, collected_at);

    COMMIT;
  `);
}

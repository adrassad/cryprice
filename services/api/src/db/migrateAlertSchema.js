/**
 * Idempotent migration: alert_rules, alerts, alert_deliveries.
 *
 * Safe to run on every startup after users, wallets, and networks exist.
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

async function prerequisitesReady(db) {
  return (
    (await tableExists(db, "users")) &&
    (await tableExists(db, "wallets")) &&
    (await tableExists(db, "networks"))
  );
}

async function ensureUpdatedAtTrigger(db, tableName, triggerName) {
  await db.query(`
    DROP TRIGGER IF EXISTS ${triggerName} ON ${tableName};
  `);
  await db.query(`
    CREATE TRIGGER ${triggerName}
    BEFORE UPDATE ON ${tableName}
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
  `);
}

export async function migrateAlertSchemaIfNeeded(db) {
  if (!(await prerequisitesReady(db))) return;

  console.log("⏱ Migrating alert schema...", new Date().toISOString());

  await db.query(`
    CREATE TABLE IF NOT EXISTS alert_rules (
      id BIGSERIAL PRIMARY KEY,
      user_id BIGINT NOT NULL
        REFERENCES users(id)
        ON DELETE CASCADE,
      type TEXT NOT NULL,
      protocol TEXT NOT NULL DEFAULT 'aave',
      wallet_id BIGINT NULL
        REFERENCES wallets(id)
        ON DELETE CASCADE,
      network_id BIGINT NULL
        REFERENCES networks(id)
        ON DELETE CASCADE,
      threshold_hf NUMERIC(10, 4) NULL,
      direction TEXT NOT NULL DEFAULT 'below',
      enabled BOOLEAN NOT NULL DEFAULT TRUE,
      cooldown_minutes INT NOT NULL DEFAULT 30,
      last_triggered_at TIMESTAMPTZ NULL,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
  `);

  await db.query(`
    CREATE TABLE IF NOT EXISTS alerts (
      id BIGSERIAL PRIMARY KEY,
      user_id BIGINT NOT NULL
        REFERENCES users(id)
        ON DELETE CASCADE,
      rule_id BIGINT NULL
        REFERENCES alert_rules(id)
        ON DELETE SET NULL,
      wallet_id BIGINT NULL
        REFERENCES wallets(id)
        ON DELETE SET NULL,
      wallet_address TEXT NULL,
      network_id BIGINT NULL
        REFERENCES networks(id)
        ON DELETE SET NULL,
      protocol TEXT NOT NULL DEFAULT 'aave',
      type TEXT NOT NULL,
      severity TEXT NOT NULL,
      title TEXT NOT NULL,
      message TEXT NOT NULL,
      previous_hf NUMERIC(20, 8) NULL,
      current_hf NUMERIC(20, 8) NULL,
      payload JSONB NOT NULL DEFAULT '{}',
      read_at TIMESTAMPTZ NULL,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
  `);

  await db.query(`
    CREATE TABLE IF NOT EXISTS alert_deliveries (
      id BIGSERIAL PRIMARY KEY,
      alert_id BIGINT NOT NULL
        REFERENCES alerts(id)
        ON DELETE CASCADE,
      channel TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'pending',
      attempts INT NOT NULL DEFAULT 0,
      last_error TEXT NULL,
      delivered_at TIMESTAMPTZ NULL,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
  `);

  await db.query(`
    CREATE INDEX IF NOT EXISTS idx_alerts_user_id_created_at
    ON alerts(user_id, created_at DESC);
  `);

  await db.query(`
    CREATE INDEX IF NOT EXISTS idx_alerts_user_id_read_at
    ON alerts(user_id, read_at);
  `);

  await db.query(`
    CREATE INDEX IF NOT EXISTS idx_alert_rules_user_id_enabled
    ON alert_rules(user_id, enabled);
  `);

  await db.query(`
    CREATE INDEX IF NOT EXISTS idx_alert_deliveries_status_channel_created_at
    ON alert_deliveries(status, channel, created_at);
  `);

  await ensureUpdatedAtTrigger(db, "alert_rules", "trg_alert_rules_updated_at");
  await ensureUpdatedAtTrigger(
    db,
    "alert_deliveries",
    "trg_alert_deliveries_updated_at",
  );

  console.log("✅ Alert schema migration complete", new Date().toISOString());
}

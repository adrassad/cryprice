import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { ok } from "node:assert";
import { test } from "node:test";

const root = join(dirname(fileURLToPath(import.meta.url)), "../..");

test("init.js runs alert schema migration", () => {
  const init = readFileSync(join(root, "src/db/init.js"), "utf8");
  ok(init.includes('from "./migrateAlertSchema.js"'));
  ok(init.includes("migrateAlertSchemaIfNeeded(postgresClient)"));
});

test("alert schema migration defines all tables and indexes", () => {
  const src = readFileSync(join(root, "src/db/migrateAlertSchema.js"), "utf8");
  ok(src.includes("CREATE TABLE IF NOT EXISTS alert_rules"));
  ok(src.includes("CREATE TABLE IF NOT EXISTS alerts"));
  ok(src.includes("CREATE TABLE IF NOT EXISTS alert_deliveries"));
  ok(src.includes("REFERENCES users(id)"));
  ok(src.includes("REFERENCES wallets(id)"));
  ok(src.includes("REFERENCES networks(id)"));
  ok(src.includes("REFERENCES alert_rules(id)"));
  ok(src.includes("REFERENCES alerts(id)"));
  ok(src.includes("idx_alerts_user_id_created_at"));
  ok(src.includes("idx_alerts_user_id_read_at"));
  ok(src.includes("idx_alert_rules_user_id_enabled"));
  ok(src.includes("idx_alert_deliveries_status_channel_created_at"));
});

test("db facade exports alert repositories", () => {
  const idx = readFileSync(join(root, "src/db/index.js"), "utf8");
  ok(idx.includes("AlertRuleRepository"));
  ok(idx.includes("AlertRepository"));
  ok(idx.includes("alertRules:"));
  ok(idx.includes("alerts:"));
});

test("alert repositories expose persistence methods", () => {
  const ruleRepo = readFileSync(
    join(root, "src/db/repositories/alertRule.repo.js"),
    "utf8",
  );
  ok(ruleRepo.includes("create"));
  ok(ruleRepo.includes("findByUserId"));
  ok(ruleRepo.includes("findByIdForUser"));
  ok(ruleRepo.includes("updateForUser"));
  ok(ruleRepo.includes("updateLastTriggeredAt"));

  const alertRepo = readFileSync(
    join(root, "src/db/repositories/alert.repo.js"),
    "utf8",
  );
  ok(alertRepo.includes("create"));
  ok(alertRepo.includes("findByUserId"));
  ok(alertRepo.includes("markRead"));
  ok(alertRepo.includes("createDelivery"));
  ok(alertRepo.includes("findPendingDeliveries"));
  ok(alertRepo.includes("updateDelivery"));
});

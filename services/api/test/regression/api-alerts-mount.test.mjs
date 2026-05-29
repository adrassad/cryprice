import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { ok } from "node:assert";
import { test } from "node:test";

const root = join(dirname(fileURLToPath(import.meta.url)), "../..");

test("API server mounts alerts and alert-rules routes", () => {
  const src = readFileSync(join(root, "src/api/server.js"), "utf8");
  ok(src.includes('from "./routes/alerts.route.js"'));
  ok(src.includes('from "./routes/alertRules.route.js"'));
  ok(src.includes('app.use("/alerts", apiLimiter)'));
  ok(src.includes('app.use("/alert-rules", apiLimiter)'));
  ok(src.includes('app.use("/alerts", requireAccessToken, alertsRoute)'));
  ok(src.includes('app.use("/alert-rules", requireAccessToken, alertRulesRoute)'));
});

test("alerts routes require auth and scope by user id", () => {
  const src = readFileSync(join(root, "src/api/routes/alerts.route.js"), "utf8");
  ok(src.includes('router.get("/", requireAccessToken'));
  ok(src.includes('router.patch("/:id/read", requireAccessToken'));
  ok(src.includes("listAlertsForUser(user.id"));
  ok(src.includes("markAlertReadForUser(user.id"));
  ok(!src.includes("req.query.userId"));
  ok(!src.includes("req.body?.userId"));
});

test("alert-rules routes require auth and scope by user id", () => {
  const src = readFileSync(join(root, "src/api/routes/alertRules.route.js"), "utf8");
  ok(src.includes('router.get("/", requireAccessToken'));
  ok(src.includes('router.post("/", requireAccessToken'));
  ok(src.includes('router.patch("/:id", requireAccessToken'));
  ok(src.includes("createAlertRuleForUser(user.id"));
  ok(src.includes("patchAlertRuleForUser(user.id"));
});

test("alert service supports unread/limit/offset query parsing", () => {
  const src = readFileSync(join(root, "src/services/alerts/alert.service.js"), "utf8");
  ok(src.includes("parseListAlertsQuery"));
  ok(src.includes("unreadOnly"));
  ok(src.includes("DEFAULT_LIMIT"));
  ok(src.includes("findByUserId(userId"));
  ok(src.includes("serializeAlertForApi"));
});

test("alert rule service validates threshold, wallet, and network scope", () => {
  const src = readFileSync(join(root, "src/services/alerts/alertRule.service.js"), "utf8");
  ok(src.includes("parseCreateAlertRuleBody"));
  ok(src.includes("parsePatchAlertRuleBody"));
  ok(src.includes("assertWalletOwnedByInternalUser"));
  ok(src.includes("assertNetworkExists"));
  ok(src.includes("HEALTH_FACTOR_RULE_TYPE"));
  ok(src.includes("cooldown_minutes: 30") || src.includes("DEFAULT_COOLDOWN_MINUTES = 30"));
});

import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";
import { ok, strictEqual } from "node:assert";
import { test } from "node:test";
import { API_IDENTITY_PAYLOAD } from "../../src/api/routes/apiIdentity.route.js";
import { withHttpTestEnv } from "./helpers/http-test-env.mjs";

const root = join(dirname(fileURLToPath(import.meta.url)), "../..");
const httpHelper = join(
  root,
  "test/regression/helpers/api-root-identity-http-check.mjs",
);

test("API_IDENTITY_PAYLOAD is static and read-only", () => {
  strictEqual(API_IDENTITY_PAYLOAD.name, "CryPrice API");
  strictEqual(API_IDENTITY_PAYLOAD.status, "ok");
  strictEqual(API_IDENTITY_PAYLOAD.readOnly, true);
  ok(API_IDENTITY_PAYLOAD.security.publicAddressesOnly);
  ok(API_IDENTITY_PAYLOAD.security.noWalletConnection);
  ok(API_IDENTITY_PAYLOAD.security.noSeedPhrases);
  ok(API_IDENTITY_PAYLOAD.security.noPrivateKeys);
  ok(API_IDENTITY_PAYLOAD.security.noSignatures);
  ok(API_IDENTITY_PAYLOAD.security.noTransactionSigning);
  ok(API_IDENTITY_PAYLOAD.security.noTransactions);
  ok(API_IDENTITY_PAYLOAD.security.noCustody);
  strictEqual(API_IDENTITY_PAYLOAD.authentication.provider, "Google OAuth");
  strictEqual(
    API_IDENTITY_PAYLOAD.authentication.purpose,
    "CryPrice account access only",
  );
  strictEqual(API_IDENTITY_PAYLOAD.authentication.notWalletAccess, true);
  ok(API_IDENTITY_PAYLOAD.notifications.telegram.includes("optional"));
  ok(API_IDENTITY_PAYLOAD.disclaimer.includes("Read-only monitoring API for public address and DeFi risk data"));
  strictEqual(API_IDENTITY_PAYLOAD.links.website, "https://cryprice.dev");
  strictEqual(API_IDENTITY_PAYLOAD.links.app, "https://app.cryprice.dev");
  strictEqual(API_IDENTITY_PAYLOAD.links.security, "https://cryprice.dev/security");
  strictEqual(API_IDENTITY_PAYLOAD.links.privacy, "https://cryprice.dev/privacy");
  strictEqual(API_IDENTITY_PAYLOAD.links.terms, "https://cryprice.dev/terms");
  strictEqual(API_IDENTITY_PAYLOAD.links.contact, "mailto:support@cryprice.dev");
  strictEqual(API_IDENTITY_PAYLOAD.links.trust, "https://cryprice.dev/trust");
  strictEqual(
    API_IDENTITY_PAYLOAD.links.transparency,
    "https://cryprice.dev/transparency",
  );
  strictEqual(
    API_IDENTITY_PAYLOAD.links.contactPage,
    "https://cryprice.dev/contact",
  );
});

test("server.js registers GET / identity", () => {
  const src = readFileSync(join(root, "src/api/server.js"), "utf8");
  ok(src.includes('app.get("/",'));
  ok(src.includes("sendApiIdentity"));
});

test("apiIdentity route does not import db, redis, or auth", () => {
  const src = readFileSync(
    join(root, "src/api/routes/apiIdentity.route.js"),
    "utf8",
  );
  ok(!src.includes("requireAccessToken"));
  ok(!src.includes("req.auth"));
  ok(!src.includes("../../db/"));
  ok(!src.includes("../../redis/"));
  ok(!src.includes("process.env"));
});

test("HTTP: GET / returns public API identity JSON", () => {
  const run = spawnSync(process.execPath, [httpHelper], {
    cwd: root,
    encoding: "utf8",
    env: withHttpTestEnv(),
  });
  strictEqual(run.status, 0, run.stderr || run.stdout);
  const lines = run.stdout.trim().split("\n").filter(Boolean);
  const jsonLine = lines.find((line) => line.startsWith("{"));
  strictEqual(JSON.parse(jsonLine).ok, true);
});

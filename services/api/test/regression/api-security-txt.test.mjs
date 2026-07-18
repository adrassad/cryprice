import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";
import { ok, strictEqual } from "node:assert";
import { test } from "node:test";
import { API_SECURITY_TXT } from "../../src/api/routes/securityTxt.route.js";

const root = join(dirname(fileURLToPath(import.meta.url)), "../..");
const httpHelper = join(
  root,
  "test/regression/helpers/api-security-txt-http-check.mjs",
);

test("API_SECURITY_TXT includes required fields only", () => {
  ok(API_SECURITY_TXT.includes("Contact: mailto:security@cryprice.dev"));
  ok(API_SECURITY_TXT.includes("Contact: https://x.com/AdrasSad"));
  ok(
    API_SECURITY_TXT.includes(
      "Acknowledgments: https://cryprice.dev/trust/#acknowledgments",
    ),
  );
  ok(API_SECURITY_TXT.includes("Policy: https://cryprice.dev/security"));
  ok(API_SECURITY_TXT.includes("Expires: 2027-01-01T00:00:00.000Z"));
  ok(API_SECURITY_TXT.includes("Preferred-Languages: en, ru"));
  ok(
    API_SECURITY_TXT.includes(
      "Canonical: https://cryprice.dev/.well-known/security.txt",
    ),
  );
  ok(!API_SECURITY_TXT.includes("dev@cryprice.dev"));
  ok(!API_SECURITY_TXT.toLowerCase().includes("bug bounty"));
});

test("server.js registers GET /.well-known/security.txt", () => {
  const src = readFileSync(join(root, "src/api/server.js"), "utf8");
  ok(src.includes('app.get("/.well-known/security.txt"'));
  ok(src.includes("sendSecurityTxt"));
});

test("securityTxt route does not import db, redis, or auth", () => {
  const src = readFileSync(
    join(root, "src/api/routes/securityTxt.route.js"),
    "utf8",
  );
  ok(!src.includes("requireAccessToken"));
  ok(!src.includes("req.auth"));
  ok(!src.includes("../../db/"));
  ok(!src.includes("../../redis/"));
  ok(!src.includes("process.env"));
});

test("HTTP: GET /.well-known/security.txt returns public plain-text metadata", () => {
  const run = spawnSync(process.execPath, [httpHelper], {
    cwd: root,
    encoding: "utf8",
    env: { ...process.env, PATH: process.env.PATH ?? "" },
  });
  strictEqual(run.status, 0, run.stderr || run.stdout);
  const lines = run.stdout.trim().split("\n").filter(Boolean);
  const jsonLine = lines.find((line) => line.startsWith("{"));
  strictEqual(JSON.parse(jsonLine).ok, true);
});

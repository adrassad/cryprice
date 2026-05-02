import { mkdtempSync } from "node:fs";
import { tmpdir } from "node:os";
import { spawnSync } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { strictEqual, ok, match } from "node:assert";
import { test } from "node:test";

const root = join(dirname(fileURLToPath(import.meta.url)), "../..");
const helper = join(root, "test/regression/helpers/import-env-meta.mjs");

function runEnvHelper(env) {
  return spawnSync(process.execPath, [helper], {
    cwd: root,
    encoding: "utf8",
    env: { ...env, PATH: env.PATH ?? process.env.PATH ?? "" },
  });
}

test("startup validation fails when DATABASE_URL is missing", () => {
  const env = {
    ...process.env,
    DATABASE_URL: "",
    BOT_TOKEN: "test-token-for-regression",
    PATH: process.env.PATH || "",
  };
  const r = runEnvHelper(env);
  ok(r.status !== 0, "process should exit non-zero");
  match(
    r.stderr + r.stdout,
    /Missing required environment variables: DATABASE_URL/,
  );
});

test("startup validation fails when BOT_TOKEN is missing", () => {
  const env = {
    ...process.env,
    DATABASE_URL: "postgres://u:p@localhost/db",
    BOT_TOKEN: "",
    PATH: process.env.PATH || "",
  };
  const r = runEnvHelper(env);
  ok(r.status !== 0);
  match(r.stderr + r.stdout, /BOT_TOKEN/);
});

test("PORT falls back to PORT when PORT_API unset", () => {
  // Empty cwd so no project .env injects PORT_API (would override PORT fallback).
  const emptyCwd = mkdtempSync(join(tmpdir(), "reg-env-"));
  const env = {
    PATH: process.env.PATH || "",
    DATABASE_URL: "postgres://u:p@localhost/db",
    BOT_TOKEN: "test-token-for-regression",
    PORT: "4001",
  };
  const r = spawnSync(process.execPath, [helper], {
    cwd: emptyCwd,
    encoding: "utf8",
    env,
  });
  strictEqual(r.status, 0, r.stderr + r.stdout);
  const meta = JSON.parse(r.stdout.trim());
  strictEqual(meta.port, 4001);
});

test("FLUSH_REDIS_ON_START is ignored when NODE_ENV=production", () => {
  const env = {
    ...process.env,
    DATABASE_URL: "postgres://u:p@localhost/db",
    BOT_TOKEN: "test-token-for-regression",
    NODE_ENV: "production",
    FLUSH_REDIS_ON_START: "true",
    PATH: process.env.PATH || "",
  };
  const r = runEnvHelper(env);
  strictEqual(r.status, 0, r.stderr + r.stdout);
  const meta = JSON.parse(r.stdout.trim());
  strictEqual(meta.flush, false);
});

test("FLUSH_REDIS_ON_START may apply when not production", () => {
  const env = {
    ...process.env,
    DATABASE_URL: "postgres://u:p@localhost/db",
    BOT_TOKEN: "test-token-for-regression",
    NODE_ENV: "development",
    FLUSH_REDIS_ON_START: "true",
    PATH: process.env.PATH || "",
  };
  const r = runEnvHelper(env);
  strictEqual(r.status, 0, r.stderr + r.stdout);
  const meta = JSON.parse(r.stdout.trim());
  strictEqual(meta.flush, true);
});

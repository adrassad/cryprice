import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { strictEqual, ok } from "node:assert";
import { test } from "node:test";

const root = join(dirname(fileURLToPath(import.meta.url)), "../..");

test("db init DDL does not reference removed monitors table", () => {
  const src = readFileSync(join(root, "src/db/init.js"), "utf8");
  ok(
    !/\bmonitors\b/i.test(src),
    "init.js must not reference monitors (orphan index regression)",
  );
});

test("PostgresClient is constructed only in connection.js", () => {
  const conn = readFileSync(join(root, "src/db/connection.js"), "utf8");
  const n = (conn.match(/new PostgresClient/g) || []).length;
  strictEqual(n, 1, "single pool construction site");
});

test("init.js and index.js import shared connection module", () => {
  const init = readFileSync(join(root, "src/db/init.js"), "utf8");
  const idx = readFileSync(join(root, "src/db/index.js"), "utf8");
  ok(init.includes('from "./connection.js"'));
  ok(idx.includes('from "./connection.js"'));
});

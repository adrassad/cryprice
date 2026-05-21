import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { ok } from "node:assert";
import { test } from "node:test";

const root = join(dirname(fileURLToPath(import.meta.url)), "../..");

test("init.js runs Phase 1 internal id migration after auth schema", () => {
  const init = readFileSync(join(root, "src/db/init.js"), "utf8");
  ok(init.includes("migrateUserInternalIdPhase1IfNeeded"));
  const authIdx = init.indexOf("migrateUserAuthSchemaIfNeeded");
  const phase1Idx = init.indexOf("migrateUserInternalIdPhase1IfNeeded");
  ok(phase1Idx > authIdx, "Phase 1 must run after user auth schema migration");
});

test("UserRepository defines findByInternalId", () => {
  const src = readFileSync(join(root, "src/db/repositories/user.repo.js"), "utf8");
  ok(
    /findByInternalId\s*\(/.test(src),
    "expected findByInternalId for users.id",
  );
});

test("Phase 1 migration module documents later phases and exports verifier", () => {
  const src = readFileSync(
    join(root, "src/db/migrateUserInternalIdPhase1.js"),
    "utf8",
  );
  ok(/PHASE 2\+/i.test(src), "expected Phase 2+ note for synthetic telegram_id / JWT");
  ok(
    /verifyUserInternalIdPhase1/.test(src),
    "expected verifyUserInternalIdPhase1 export",
  );
});

test("auth_identities insert sets user_id with COALESCE", () => {
  const src = readFileSync(
    join(root, "src/db/repositories/authIdentity.repo.js"),
    "utf8",
  );
  ok(/user_id/.test(src) && /COALESCE\s*\(\$4/.test(src));
});

test("refresh_tokens insert populates user_id from users", () => {
  const src = readFileSync(
    join(root, "src/db/repositories/refreshToken.repo.js"),
    "utf8",
  );
  ok(/user_id/.test(src) && /FROM users u/.test(src));
});

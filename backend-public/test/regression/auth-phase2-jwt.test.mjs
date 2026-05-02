import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { strictEqual, ok, match } from "node:assert";
import { test } from "node:test";
import jwt from "jsonwebtoken";
import "dotenv/config";
import {
  signAccessToken,
  verifyAccessToken,
  JWT_SUB_TYP_USER_ID,
} from "../../src/services/auth/jwt.tokens.js";
import { ENV } from "../../src/config/env.js";

const root = join(dirname(fileURLToPath(import.meta.url)), "../..");

test("new access JWT: sub is users.id and sub_typ is user_id", () => {
  const internalId = 4242;
  const token = signAccessToken(internalId);
  const payload = verifyAccessToken(token);
  strictEqual(payload.sub, "4242");
  strictEqual(payload.sub_typ, JWT_SUB_TYP_USER_ID);
  strictEqual(payload.typ, "access");
});

test("new access JWT round-trip with bigint-like id", () => {
  const token = signAccessToken("999001");
  const payload = verifyAccessToken(token);
  strictEqual(payload.sub, "999001");
  strictEqual(payload.sub_typ, "user_id");
});

test("legacy access JWT (no sub_typ) still verifies and sub is telegram_id shape", () => {
  const legacy = jwt.sign(
    { typ: "access", sub: "-1000000001" },
    ENV.JWT_ACCESS_SECRET,
    {
      expiresIn: "15m",
      issuer: ENV.JWT_ISSUER,
      audience: ENV.JWT_AUDIENCE,
    },
  );
  const payload = verifyAccessToken(legacy);
  strictEqual(payload.sub, "-1000000001");
  strictEqual(payload.sub_typ, undefined);
});

test("getMe and refreshSession use internal id in source", () => {
  const src = readFileSync(join(root, "src/services/auth/auth.service.js"), "utf8");
  ok(src.includes("findByInternalId"), "getMe/refresh should resolve by users.id");
  ok(src.includes("signAccessToken(user.id)"), "access token must use user.id");
  ok(/getMe\(\s*userId/.test(src) || src.includes("getMe(userId)"), "getMe takes userId");
});

test("Google login still keys identity by provider + Google sub", () => {
  const src = readFileSync(join(root, "src/services/auth/auth.service.js"), "utf8");
  ok(
    /findByProviderUserId\s*\(\s*PROVIDER_GOOGLE\s*,\s*gp\.sub/.test(
      src.replace(/\n/g, " "),
    ) ||
      src.includes("findByProviderUserId(") && src.includes("gp.sub"),
    "expected findByProviderUserId(…, gp.sub) for Google",
  );
  ok(
    /provider_user_id:\s*gp\.sub/.test(src),
    "auth identity must store Google sub as provider_user_id",
  );
});

test("requireAccessToken sets userId; legacy path documented in middleware", () => {
  const src = readFileSync(
    join(root, "src/api/middlewares/auth.middleware.js"),
    "utf8",
  );
  ok(src.includes("req.auth = { userId:"), "canonical session is userId");
  ok(
    /sub_typ === JWT_SUB_TYP_USER_ID|JWT_SUB_TYP_USER_ID.*sub_typ/.test(src),
  );
  ok(src.includes("findById(payload.sub)"), "legacy: sub as telegram_id");
});

test("toPublicUser includes id and telegram_id for /auth/me", () => {
  const src = readFileSync(join(root, "src/services/auth/auth.service.js"), "utf8");
  ok(
    /id:\s*row\.id/.test(src),
    "toPublicUser should expose id",
  );
  ok(src.includes("telegram_id: row.telegram_id"));
});

test("rotateRefreshToken returns userId for refresh session", () => {
  const src = readFileSync(
    join(root, "src/db/repositories/refreshToken.repo.js"),
    "utf8",
  );
  ok(
    /userId:\s*userId\s*!=\s*null/.test(src.replace(/\s+/g, " ")) ||
      src.includes("userId: userId !=") ||
      src.includes("String(userId)"),
  );
  const authSrc = readFileSync(join(root, "src/services/auth/auth.service.js"), "utf8");
  ok(
    authSrc.includes("rotated.userId") && authSrc.includes("findByInternalId"),
    "refreshSession should prefer userId + findByInternalId",
  );
});

test("auth route /me uses req.auth.userId", () => {
  const src = readFileSync(join(root, "src/api/routes/auth.route.js"), "utf8");
  ok(src.includes("getMe(req.auth.userId)"));
});

test("Telegram bot entrypoints unchanged: createIfNotExists / start", () => {
  const start = readFileSync(
    join(root, "src/bot/commands/start.command.js"),
    "utf8",
  );
  ok(start.includes("createIfNotExists"));
  const userSvc = readFileSync(
    join(root, "src/services/user/user.service.js"),
    "utf8",
  );
  ok(userSvc.includes("db.users.create"));
});

import { strictEqual, ok, throws } from "node:assert";
import { test } from "node:test";
import {
  parseCorsAllowedOrigins,
  resolveCorsOriginPolicy,
  isLocalDevOrigin,
} from "../../src/config/cors.policy.js";

test("parseCorsAllowedOrigins splits comma-separated values", () => {
  strictEqual(
    parseCorsAllowedOrigins("https://a.test, https://b.test").join(","),
    "https://a.test,https://b.test",
  );
});

test("resolveCorsOriginPolicy rejects wildcard", () => {
  throws(
    () => resolveCorsOriginPolicy("production", ["*"]),
    /wildcard/i,
  );
});

test("resolveCorsOriginPolicy requires origins in production", () => {
  throws(
    () => resolveCorsOriginPolicy("production", []),
    /CORS_ALLOWED_ORIGINS is required in production/,
  );
});

test("resolveCorsOriginPolicy allows localhost policy in development", () => {
  strictEqual(resolveCorsOriginPolicy("development", []), null);
});

test("resolveCorsOriginPolicy returns explicit list when configured", () => {
  const origins = ["https://app.cryprice.dev", "https://cryprice.dev"];
  strictEqual(
    resolveCorsOriginPolicy("production", origins),
    origins,
  );
});

test("isLocalDevOrigin accepts localhost and missing origin", () => {
  ok(isLocalDevOrigin(undefined));
  ok(isLocalDevOrigin("http://localhost:3000"));
  ok(isLocalDevOrigin("http://127.0.0.1:5000"));
  ok(!isLocalDevOrigin("https://app.cryprice.dev"));
});

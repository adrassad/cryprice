import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { ok } from "node:assert";
import { test } from "node:test";

const root = join(dirname(fileURLToPath(import.meta.url)), "../..");

test("API server mounts portfolio routes with shared rate limiter", () => {
  const src = readFileSync(join(root, "src/api/server.js"), "utf8");
  ok(src.includes('from "./routes/portfolio.route.js"'));
  ok(src.includes('app.use("/portfolio", apiLimiter)'));
  ok(src.includes('app.use("/portfolio", portfolioRoute)'));
});

test("portfolio root route exposes authenticated aggregated portfolio", () => {
  const src = readFileSync(join(root, "src/api/routes/portfolio.route.js"), "utf8");

  ok(src.includes("getAggregatedUserPortfolio"));
  ok(src.includes('router.get("/", requireAccessToken'));
  ok(src.includes("getAggregatedUserPortfolio(req.auth.userId"));
  ok(src.includes("includeWallets: parseIncludeWallets(req.query.includeWallets)"));
});

test("portfolio root route does not accept client-supplied user id", () => {
  const src = readFileSync(join(root, "src/api/routes/portfolio.route.js"), "utf8");

  ok(!src.includes("req.query.userId"));
  ok(!src.includes("req.query.user_id"));
  ok(!src.includes("req.body?.userId"));
  ok(!src.includes("req.body?.user_id"));
  ok(!src.includes("req.params.userId"));
  ok(!src.includes("req.params.user_id"));
});

test("existing portfolio routes remain present", () => {
  const src = readFileSync(join(root, "src/api/routes/portfolio.route.js"), "utf8");

  ok(src.includes('router.get("/export/pdf", requireAccessToken'));
  ok(src.includes('router.get("/me", requireAccessToken'));
  ok(src.includes('router.get("/wallet/:walletId", requireAccessToken'));
  ok(src.includes('router.post("/sync", requireAccessToken'));
});

import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { ok } from "node:assert";
import { test } from "node:test";

const root = join(dirname(fileURLToPath(import.meta.url)), "../..");

test("portfolio aggregation repository uses internal user ownership filter", () => {
  const src = readFileSync(
    join(root, "src/db/repositories/portfolioAggregation.repo.js"),
    "utf8",
  );

  ok(src.includes("findRawRowsByInternalUserId(internalUserId)"));
  ok(src.includes("FROM wallets w"));
  ok(src.includes("WHERE w.user_id = $1"));
  ok(src.includes("[internalUserId]"));
  ok(!src.includes("telegram_id"));
  ok(!src.includes("req."));
});

test("portfolio aggregation repository joins balances, assets, networks, and prices", () => {
  const src = readFileSync(
    join(root, "src/db/repositories/portfolioAggregation.repo.js"),
    "utf8",
  );

  ok(src.includes("INNER JOIN wallet_portfolio_balances b"));
  ok(src.includes("ON b.wallet_id = w.id"));
  ok(src.includes("INNER JOIN assets a"));
  ok(src.includes("ON a.id = b.asset_id"));
  ok(src.includes("INNER JOIN networks n"));
  ok(src.includes("ON n.id = a.network_id"));
  ok(src.includes("LEFT JOIN current_onchain_prices p"));
  ok(src.includes("ON p.network_id = a.network_id"));
  ok(src.includes("AND p.asset_id = a.id"));
  ok(src.includes("AND n.enabled = TRUE"));
});

test("portfolio aggregation repository returns raw numeric fields as strings", () => {
  const src = readFileSync(
    join(root, "src/db/repositories/portfolioAggregation.repo.js"),
    "utf8",
  );

  ok(src.includes("b.balance_raw::text AS balance_raw"));
  ok(src.includes("p.price_usd::text AS price_usd"));
  ok(!src.includes("Number("));
});

test("db facade exposes portfolio aggregation repository", () => {
  const src = readFileSync(join(root, "src/db/index.js"), "utf8");

  ok(src.includes("PortfolioAggregationRepository"));
  ok(src.includes("portfolioAggregation: new PortfolioAggregationRepository"));
});

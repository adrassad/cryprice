import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { readFileSync } from "node:fs";
import { strictEqual, ok } from "node:assert";
import { test } from "node:test";

import { isValidPortfolioSnapshot } from "../../src/services/portfolio/portfolio.cache.validation.js";
import {
  computeDesiredPositiveAssetIds,
  extractNativePositions,
} from "../../src/services/portfolio/portfolio.sync.helpers.js";

const root = join(dirname(fileURLToPath(import.meta.url)), "../..");

test("cache validation rejects mismatched walletId or malformed snapshot", () => {
  ok(!isValidPortfolioSnapshot(1, null));
  ok(!isValidPortfolioSnapshot(1, {}));
  ok(!isValidPortfolioSnapshot(1, { walletId: "2", native: [], positions: [] }));
  ok(isValidPortfolioSnapshot(1, { walletId: "1", native: [], positions: [] }));
});

test("computeDesiredPositiveAssetIds ignores bad networks/tokens", () => {
  strictEqual(
    computeDesiredPositiveAssetIds(null).size,
    0,
    "null collected",
  );
  strictEqual(
    computeDesiredPositiveAssetIds({ networks: null }).size,
    0,
  );

  const ids = computeDesiredPositiveAssetIds({
    networks: [
      { status: "skipped", tokens: [{ assetId: "1" }] },
      {
        status: "ok",
        tokens: [
          null,
          {},
          { assetId: "10", balanceRaw: "1" },
          { assetId: "", balanceRaw: "1" },
        ],
      },
    ],
  });
  ok(ids.has("10"));
  ok(!ids.has("1"));
});

test("extractNativePositions skips incomplete native payloads", () => {
  strictEqual(extractNativePositions({}).length, 0);
  const one = extractNativePositions({
    networks: [
      {
        status: "ok",
        networkId: 1,
        networkName: "eth",
        chainId: 1,
        native: { symbol: "ETH", decimals: 18, balanceRaw: "5" },
      },
      {
        status: "ok",
        native: null,
      },
    ],
  });
  strictEqual(one.length, 1);
  strictEqual(one[0].balanceRaw, "5");
});

test("DDL keeps balance_raw strictly positive for persisted rows", () => {
  const initSrc = readFileSync(join(root, "src/db/init.js"), "utf8");
  ok(initSrc.includes("CHECK (balance_raw > 0)"));
});

test("repository upsert rejects non-positive balance_raw", () => {
  const repoSrc = readFileSync(
    join(root, "src/db/repositories/walletPortfolio.repo.js"),
    "utf8",
  );
  ok(repoSrc.includes("n <= 0n"));
});

test("collector omits zero erc20 balances", () => {
  const collSrc = readFileSync(
    join(root, "src/services/portfolio/portfolio.collector.js"),
    "utf8",
  );
  ok(collSrc.includes("raw <= 0n"));
});

test("asset enrichment SQL ANY lives in repository layer", () => {
  const assetRepoSrc = readFileSync(
    join(root, "src/db/repositories/asset.repo.js"),
    "utf8",
  );
  ok(assetRepoSrc.includes("WHERE id = ANY($1::bigint[])"));
});

test("portfolio service delegates DB sync/prune to repository", () => {
  const svcSrc = readFileSync(
    join(root, "src/services/portfolio/portfolio.service.js"),
    "utf8",
  );
  ok(svcSrc.includes("db.walletPortfolio.syncCollectedSnapshotWithLock("));
  ok(!svcSrc.includes("UPSERT_SQL"));
  ok(!svcSrc.includes("DELETE FROM wallet_portfolio_balances"));
  ok(!svcSrc.includes("postgresClient.pool.connect"));
});

test("walletPortfolio repository contains lock + batch sync implementation", () => {
  const repoSrc = readFileSync(
    join(root, "src/db/repositories/walletPortfolio.repo.js"),
    "utf8",
  );
  ok(repoSrc.includes("syncCollectedSnapshotWithLock("));
  ok(repoSrc.includes("pg_try_advisory_lock"));
  ok(repoSrc.includes("pg_advisory_unlock"));
  ok(repoSrc.includes("UPSERT_SQL"));
  ok(repoSrc.includes("DELETE_ROW_SQL"));
});

test("getUserPortfolio aggregates each wallet via getWalletPortfolio", () => {
  const svcSrc = readFileSync(
    join(root, "src/services/portfolio/portfolio.service.js"),
    "utf8",
  );
  ok(svcSrc.includes("for (const w of walletsMap.values())"));
  ok(svcSrc.includes("getWalletPortfolio(w.id)"));
});

test("read-through invalidates corrupt Redis snapshot shapes", () => {
  const svcSrc = readFileSync(
    join(root, "src/services/portfolio/portfolio.service.js"),
    "utf8",
  );
  ok(svcSrc.includes("isValidPortfolioSnapshot(walletId, cached)"));
});

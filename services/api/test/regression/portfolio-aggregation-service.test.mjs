import { deepStrictEqual, strictEqual, ok } from "node:assert";
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { test } from "node:test";

import {
  buildPortfolioAggregationFromRows,
  DEFAULT_PRICE_STALE_AFTER_MS,
} from "../../src/services/portfolio/portfolioAggregation.service.js";

const root = join(dirname(fileURLToPath(import.meta.url)), "../..");
const NOW = "2026-05-19T13:30:00.000Z";

function baseRow(overrides = {}) {
  return {
    wallet_id: "1",
    wallet_address: "0x1111111111111111111111111111111111111111",
    wallet_label: "Main",
    asset_id: "10",
    balance_raw: "100000000",
    balance_synced_at: "2026-05-19T13:21:00.000Z",
    block_number: "22500111",
    network_id: 1,
    asset_address: "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
    asset_symbol: "USDC",
    asset_decimals: 6,
    chain_id: 1,
    network_name: "ethereum",
    native_symbol: "ETH",
    price_usd: "1.0001",
    price_calculated_at: "2026-05-19T13:20:00.000Z",
    price_updated_at: "2026-05-19T13:20:10.000Z",
    ...overrides,
  };
}

function aggregate(rows) {
  return buildPortfolioAggregationFromRows(rows, {
    now: NOW,
    staleAfterMs: DEFAULT_PRICE_STALE_AFTER_MS,
  });
}

test("portfolio aggregation returns empty object for user with no raw rows", () => {
  deepStrictEqual(aggregate([]), {
    summary: {
      totalValueUsd: "0.00",
      walletsCount: 0,
      assetsCount: 0,
      networksCount: 0,
      updatedAt: null,
    },
    networks: [],
  });
});

test("same asset in two wallets aggregates into one asset with wallet breakdown", () => {
  const out = aggregate([
    baseRow(),
    baseRow({
      wallet_id: "2",
      wallet_address: "0x2222222222222222222222222222222222222222",
      wallet_label: null,
      balance_raw: "150000000",
      balance_synced_at: "2026-05-19T13:22:00.000Z",
      block_number: "22500112",
    }),
  ]);

  strictEqual(out.summary.walletsCount, 2);
  strictEqual(out.summary.assetsCount, 1);
  strictEqual(out.summary.networksCount, 1);
  strictEqual(out.summary.totalValueUsd, "250.03");
  strictEqual(out.summary.updatedAt, "2026-05-19T13:22:00.000Z");

  const asset = out.networks[0].assets[0];
  strictEqual(asset.assetId, "10");
  strictEqual(asset.balanceRaw, "250000000");
  strictEqual(asset.balance, "250.0");
  strictEqual(asset.priceUsd, "1.0001");
  strictEqual(asset.valueUsd, "250.03");
  strictEqual(asset.priceStatus, "ok");
  strictEqual(asset.balanceSyncedAt, "2026-05-19T13:22:00.000Z");
  deepStrictEqual(
    asset.wallets.map((wallet) => ({
      walletId: wallet.walletId,
      balance: wallet.balance,
      valueUsd: wallet.valueUsd,
      label: wallet.label,
    })),
    [
      { walletId: "1", balance: "100.0", valueUsd: "100.01", label: "Main" },
      { walletId: "2", balance: "150.0", valueUsd: "150.02", label: null },
    ],
  );
});

test("portfolio aggregation can omit wallet breakdowns", () => {
  const out = buildPortfolioAggregationFromRows([baseRow()], {
    now: NOW,
    staleAfterMs: DEFAULT_PRICE_STALE_AFTER_MS,
    includeWallets: false,
  });

  deepStrictEqual(out.networks[0].assets[0].wallets, []);
});

test("same symbol on two networks remains two separate assets", () => {
  const out = aggregate([
    baseRow(),
    baseRow({
      wallet_id: "3",
      wallet_address: "0x3333333333333333333333333333333333333333",
      asset_id: "20",
      network_id: 2,
      chain_id: 42161,
      network_name: "arbitrum",
      native_symbol: "ETH",
      asset_address: "0xaf88d065e77c8cc2239327c5edb3a432268e5831",
      asset_symbol: "USDC",
      balance_raw: "50000000",
      price_usd: null,
      price_calculated_at: null,
      price_updated_at: null,
    }),
  ]);

  strictEqual(out.summary.assetsCount, 2);
  strictEqual(out.summary.networksCount, 2);
  deepStrictEqual(
    out.networks.map((network) => ({
      networkId: network.networkId,
      assetIds: network.assets.map((asset) => asset.assetId),
      symbols: network.assets.map((asset) => asset.symbol),
    })),
    [
      { networkId: 1, assetIds: ["10"], symbols: ["USDC"] },
      { networkId: 2, assetIds: ["20"], symbols: ["USDC"] },
    ],
  );
});

test("missing price returns null value and missing status", () => {
  const out = aggregate([
    baseRow({
      price_usd: null,
      price_calculated_at: null,
      price_updated_at: null,
    }),
  ]);

  const asset = out.networks[0].assets[0];
  strictEqual(asset.priceUsd, null);
  strictEqual(asset.valueUsd, null);
  strictEqual(asset.priceStatus, "missing");
  strictEqual(asset.wallets[0].valueUsd, null);
  strictEqual(out.summary.totalValueUsd, "0.00");
});

test("stale price returns stale status while keeping calculated USD value", () => {
  const out = aggregate([
    baseRow({
      asset_id: "11",
      asset_symbol: "WETH",
      asset_decimals: 18,
      asset_address: "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
      balance_raw: "1000000000000000000",
      price_usd: "2000",
      price_calculated_at: "2026-05-19T10:00:00.000Z",
    }),
  ]);

  const asset = out.networks[0].assets[0];
  strictEqual(asset.priceStatus, "stale");
  strictEqual(asset.priceUsd, "2000");
  strictEqual(asset.valueUsd, "2000.00");
  strictEqual(asset.wallets[0].valueUsd, "2000.00");
});

test("portfolio total excludes null values and assets sort by value then symbol", () => {
  const out = aggregate([
    baseRow(),
    baseRow({
      asset_id: "11",
      asset_symbol: "WETH",
      asset_decimals: 18,
      asset_address: "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
      balance_raw: "1000000000000000000",
      price_usd: "2000",
      price_calculated_at: "2026-05-19T10:00:00.000Z",
    }),
    baseRow({
      asset_id: "12",
      asset_symbol: "AAVE",
      asset_decimals: 18,
      asset_address: "0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
      balance_raw: "5000000000000000000",
      price_usd: null,
      price_calculated_at: null,
    }),
  ]);

  strictEqual(out.networks[0].totalValueUsd, "2100.01");
  strictEqual(out.summary.totalValueUsd, "2100.01");
  deepStrictEqual(
    out.networks[0].assets.map((asset) => asset.symbol),
    ["WETH", "USDC", "AAVE"],
  );
});

test("portfolio aggregation exposes local logo_url from asset metadata", () => {
  const sampleHash =
    "a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3";
  const out = aggregate([
    baseRow({
      asset_logo_status: "ready",
      asset_logo_local_path:
        "1/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48.png",
      asset_logo_content_hash: sampleHash,
    }),
    baseRow({
      asset_id: "11",
      asset_logo_status: "pending",
      asset_logo_local_path: null,
    }),
  ]);

  strictEqual(
    out.networks[0].assets.find((asset) => asset.assetId === "10")?.logo_url,
    `/static/token-icons/1/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48.png?v=${sampleHash}`,
  );
  strictEqual(
    out.networks[0].assets.find((asset) => asset.assetId === "11")?.logo_url,
    null,
  );
});

test("portfolio aggregation service avoids unsafe Number conversion paths", () => {
  const src = readFileSync(
    join(root, "src/services/portfolio/portfolioAggregation.service.js"),
    "utf8",
  );

  ok(!src.includes("Number("));
  ok(src.includes("network_id"));
  ok(src.includes("asset_id"));
  ok(src.includes("`${networkId}:${assetId}`"));
  ok(!src.includes("`${networkId}:${row.asset_symbol}`"));
});

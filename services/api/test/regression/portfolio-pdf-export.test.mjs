import { strictEqual, ok } from "node:assert";
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { test } from "node:test";

import {
  buildDefiPositionGroups,
  findPositionHealth,
  generatePortfolioPdf,
} from "../../src/services/portfolio/portfolioPdfExport.service.js";
import {
  formatUsd,
  portfolioReportFilename,
  shortAddress,
} from "../../src/services/portfolio/portfolioPdfFormat.js";

const root = join(dirname(fileURLToPath(import.meta.url)), "../..");

function emptyPortfolio() {
  return {
    summary: {
      totalValueUsd: "0.00",
      walletsCount: 0,
      assetsCount: 0,
      networksCount: 0,
      updatedAt: null,
      walletValueUsd: "0.00",
      suppliedValueUsd: "0.00",
      borrowedValueUsd: "0.00",
      grossValueUsd: "0.00",
      netValueUsd: "0.00",
      healthFactor: null,
      healthFactorStatus: "missing",
      healthFactorStatusLabel: "Missing",
    },
    totals: {
      walletValueUsd: "0.00",
      suppliedValueUsd: "0.00",
      borrowedValueUsd: "0.00",
      grossValueUsd: "0.00",
      netValueUsd: "0.00",
    },
    wallets: [],
    protocolSummaries: [
      {
        protocol: "wallet",
        protocolName: "Wallet",
        category: "wallet",
        walletValueUsd: "0.00",
        suppliedValueUsd: "0.00",
        borrowedValueUsd: "0.00",
        grossValueUsd: "0.00",
        netValueUsd: "0.00",
        totalValueUsd: "0.00",
        healthFactor: null,
        healthFactorStatus: "none",
        healthFactorStatusLabel: null,
        networks: [],
      },
    ],
    walletHoldings: [],
    protocolPositions: { supplied: [], borrowed: [] },
    defiRisk: {
      healthFactor: {
        value: null,
        status: "missing",
        statusLabel: "Missing",
        protocol: null,
        protocolName: null,
        updatedAt: null,
        stale: false,
      },
      positionsHealth: [],
    },
    allocation: {
      assets: [],
      debts: [],
      protocols: [],
      networks: [],
      wallets: [],
    },
    networks: [],
  };
}

function samplePortfolio() {
  return {
    ...emptyPortfolio(),
    summary: {
      totalValueUsd: "366.77",
      walletsCount: 1,
      assetsCount: 2,
      networksCount: 2,
      updatedAt: "2026-05-20T20:26:47.136Z",
      walletValueUsd: "100.00",
      suppliedValueUsd: "4000.00",
      borrowedValueUsd: "4033.40",
      grossValueUsd: "4100.00",
      netValueUsd: "66.60",
      healthFactor: "1.61",
      healthFactorStatus: "at_risk",
      healthFactorStatusLabel: "At risk",
    },
    totals: {
      walletValueUsd: "100.00",
      suppliedValueUsd: "4000.00",
      borrowedValueUsd: "4033.40",
      grossValueUsd: "4100.00",
      netValueUsd: "66.60",
    },
    wallets: [
      {
        walletId: "4",
        walletAddress: "0x1111111111111111111111111111111111111111",
        walletLabel: "TW",
        walletValueUsd: "100.00",
        suppliedValueUsd: "4000.00",
        borrowedValueUsd: "4033.40",
        grossValueUsd: "4100.00",
        netValueUsd: "66.60",
        healthFactor: "1.61",
        healthFactorStatus: "at_risk",
        healthFactorStatusLabel: "At risk",
      },
    ],
    walletHoldings: [
      {
        assetSymbol: "UNI",
        symbol: "UNI",
        networkName: "Ethereum",
        network: "ethereum",
        amount: "1.0",
        priceUsd: "3.50",
        valueUsd: "3.50",
        priceStatus: "ok",
      },
    ],
    protocolPositions: {
      supplied: [
        {
          protocol: "aave_v3",
          protocolName: "Aave V3",
          networkId: 2,
          network: "arbitrum",
          networkName: "Arbitrum",
          underlyingSymbol: "WBTC",
          tokenSymbol: "aArbWBTC",
          priceUsd: "70000",
          priceStatus: "ok",
          wallets: [
            {
              walletId: "4",
              walletAddress: "0x1111111111111111111111111111111111111111",
              walletLabel: "TW",
              amount: "0.05",
              valueUsd: "4000.00",
            },
          ],
        },
      ],
      borrowed: [
        {
          protocol: "aave_v3",
          protocolName: "Aave V3",
          networkId: 2,
          network: "arbitrum",
          networkName: "Arbitrum",
          underlyingSymbol: "USD₮0",
          tokenSymbol: "variableDebtArbUSDT",
          debtType: "variable",
          priceUsd: "0.99",
          priceStatus: "ok",
          wallets: [
            {
              walletId: "4",
              walletAddress: "0x1111111111111111111111111111111111111111",
              walletLabel: "TW",
              amount: "4033.40",
              valueUsd: "4033.40",
            },
          ],
        },
      ],
    },
    defiRisk: {
      healthFactor: {
        value: "1.61",
        status: "at_risk",
        statusLabel: "At risk",
        protocol: "aave_v3",
        protocolName: "Aave V3",
        updatedAt: "2026-05-20T17:04:59.000Z",
        stale: true,
      },
      positionsHealth: [
        {
          walletId: "4",
          walletAddress: "0x1111111111111111111111111111111111111111",
          walletLabel: "TW",
          protocol: "aave_v3",
          protocolName: "Aave V3",
          networkId: 2,
          network: "arbitrum",
          networkName: "Arbitrum",
          healthFactor: "1.61",
          status: "at_risk",
          statusLabel: "At risk",
          updatedAt: "2026-05-20T17:04:59.000Z",
          stale: true,
        },
      ],
    },
    allocation: {
      assets: [
        {
          key: "WBTC",
          label: "WBTC",
          valueUsd: "4000.00",
          percentage: "97.56",
          source: "supplied",
        },
        {
          key: "UNI",
          label: "UNI",
          valueUsd: "100.00",
          percentage: "2.44",
          source: "wallet",
        },
      ],
      debts: [
        {
          key: "USD₮0",
          label: "USD₮0",
          valueUsd: "4033.40",
          percentage: "100.00",
          source: "borrowed",
        },
      ],
      protocols: [
        {
          key: "aave_v3",
          label: "Aave V3",
          valueUsd: "66.60",
          percentage: "40.00",
          protocol: "aave_v3",
          netValueUsd: "66.60",
        },
        {
          key: "wallet",
          label: "Wallet",
          valueUsd: "100.00",
          percentage: "60.00",
          protocol: "wallet",
          netValueUsd: "100.00",
        },
      ],
      networks: [
        {
          key: "arbitrum",
          label: "Arbitrum",
          valueUsd: "66.60",
          percentage: "100.00",
          netValueUsd: "66.60",
        },
      ],
      wallets: [],
    },
  };
}

test("portfolio PDF export route requires auth and uses authenticated user id", () => {
  const src = readFileSync(join(root, "src/api/routes/portfolio.route.js"), "utf8");
  ok(src.includes('router.get("/export/pdf", requireAccessToken'));
  ok(src.includes("getAggregatedUserPortfolio(req.auth.userId"));
  ok(!src.includes("req.query.userId"));
  ok(!src.includes("req.query.user_id"));
});

test("generatePortfolioPdf returns a PDF buffer", async () => {
  const buffer = await generatePortfolioPdf(samplePortfolio());
  ok(Buffer.isBuffer(buffer));
  strictEqual(buffer.slice(0, 4).toString("utf8"), "%PDF");
});

test("empty portfolio PDF generation does not crash", async () => {
  const buffer = await generatePortfolioPdf(emptyPortfolio());
  ok(Buffer.isBuffer(buffer));
  strictEqual(buffer.slice(0, 4).toString("utf8"), "%PDF");
});

test("buildDefiPositionGroups separates supplied and borrowed", () => {
  const groups = buildDefiPositionGroups(samplePortfolio());
  strictEqual(groups.length, 1);
  strictEqual(groups[0].supplied.length, 1);
  strictEqual(groups[0].borrowed.length, 1);
  strictEqual(groups[0].supplied[0].position.underlyingSymbol, "WBTC");
  strictEqual(groups[0].borrowed[0].position.underlyingSymbol, "USD₮0");
  strictEqual(groups[0].health?.healthFactor, "1.61");
});

test("allocation assets exclude debt labels in sample portfolio", () => {
  const portfolio = samplePortfolio();
  ok(portfolio.allocation.assets.every((item) => item.source !== "borrowed"));
  ok(!portfolio.allocation.assets.some((item) => item.label === "USD₮0"));
  ok(portfolio.allocation.debts.some((item) => item.label === "USD₮0"));
});

test("borrowed nested values remain positive in DeFi groups", () => {
  const groups = buildDefiPositionGroups(samplePortfolio());
  const borrowed = groups[0].borrowed[0].nested.valueUsd;
  ok(!String(borrowed).startsWith("-"));
  strictEqual(borrowed, "4033.40");
});

test("findPositionHealth matches by walletId and falls back to address", () => {
  const rows = samplePortfolio().defiRisk.positionsHealth;
  const group = {
    protocol: "aave_v3",
    networkId: 2,
    walletId: "4",
    walletAddress: "0x1111111111111111111111111111111111111111",
  };
  ok(findPositionHealth(rows, group));
  ok(
    findPositionHealth(rows, {
      ...group,
      walletId: "999",
      walletAddress: "0x1111111111111111111111111111111111111111",
    }),
  );
});

test("format helpers", () => {
  strictEqual(formatUsd("1234.56"), "$1234.56");
  strictEqual(shortAddress("0x1111111111111111111111111111111111111111"), "0x1111...1111");
  ok(portfolioReportFilename(new Date("2026-05-20T12:00:00.000Z")).includes("2026-05-20"));
});

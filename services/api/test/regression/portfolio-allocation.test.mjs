import { deepStrictEqual, strictEqual, ok } from "node:assert";
import { test } from "node:test";
import Decimal from "decimal.js";

import {
  buildAssetAllocation,
  buildDebtAllocation,
  buildNetworkAllocation,
  buildPortfolioAllocation,
  buildProtocolAllocation,
  buildWalletAllocations,
  buildWalletAssetAllocation,
  buildWalletDebtAllocation,
  buildWalletNetworkAllocation,
  buildWalletProtocolAllocation,
  calculatePercentages,
  findNestedWalletEntry,
  groupSmallAllocationItems,
  normalizeAllocationLabel,
} from "../../src/services/portfolio/portfolioAllocation.mapper.js";

function sumPercentages(items) {
  return items.reduce(
    (sum, item) => sum.plus(new Decimal(item.percentage ?? "0")),
    new Decimal(0),
  );
}

function nestedWallet(walletId, overrides = {}) {
  return {
    walletId: String(walletId),
    address: `0xwallet${walletId}`,
    label: `Wallet ${walletId}`,
    walletAddress: `0xwallet${walletId}`,
    walletLabel: `Wallet ${walletId}`,
    valueUsd: "100.00",
    amount: "100.0",
    ...overrides,
  };
}

function holding(overrides = {}) {
  return {
    kind: "wallet_holding",
    networkId: 1,
    network: "ethereum",
    networkName: "Ethereum",
    assetSymbol: "USDC",
    symbol: "USDC",
    valueUsd: "100.00",
    priceUsd: "1.00",
    priceStatus: "ok",
    wallets: [nestedWallet("1", { valueUsd: "100.00" })],
    ...overrides,
  };
}

function supplied(overrides = {}) {
  return {
    kind: "protocol_position",
    protocol: "aave_v3",
    protocolName: "Aave V3",
    networkId: 2,
    network: "arbitrum",
    networkName: "Arbitrum",
    positionSide: "supplied",
    underlyingSymbol: "WBTC",
    tokenSymbol: "aArbWBTC",
    valueUsd: "4000.00",
    priceUsd: "70000",
    priceStatus: "ok",
    wallets: [nestedWallet("1", { valueUsd: "4000.00", amount: "0.05" })],
    ...overrides,
  };
}

function borrowed(overrides = {}) {
  return {
    kind: "protocol_position",
    protocol: "aave_v3",
    protocolName: "Aave V3",
    networkId: 2,
    network: "arbitrum",
    networkName: "Arbitrum",
    positionSide: "borrowed",
    underlyingSymbol: "USD₮0",
    tokenSymbol: "variableDebtArbUSDT",
    valueUsd: "4033.40",
    debtType: "variable",
    priceUsd: "0.99",
    priceStatus: "ok",
    wallets: [nestedWallet("1", { valueUsd: "4033.40", amount: "4033.40" })],
    ...overrides,
  };
}

function walletSelector(walletId, overrides = {}) {
  return {
    walletId: String(walletId),
    walletAddress: `0xwallet${walletId}`,
    walletLabel: `Wallet ${walletId}`,
    walletValueUsd: "0.00",
    suppliedValueUsd: "0.00",
    borrowedValueUsd: "0.00",
    grossValueUsd: "0.00",
    netValueUsd: "0.00",
    ...overrides,
  };
}

test("normalizeAllocationLabel trims and falls back", () => {
  strictEqual(normalizeAllocationLabel("  WBTC "), "WBTC");
  strictEqual(normalizeAllocationLabel(""), "Unknown");
});

test("assets: wallet holdings only", () => {
  const assets = buildAssetAllocation([holding()], { supplied: [], borrowed: [] });
  strictEqual(assets.length, 1);
  strictEqual(assets[0].source, "wallet");
  strictEqual(assets[0].protocol, "wallet");
  strictEqual(assets[0].percentage, "100.00");
});

test("assets: supplied only uses underlyingSymbol not tokenSymbol", () => {
  const assets = buildAssetAllocation([], {
    supplied: [supplied()],
    borrowed: [],
  });
  strictEqual(assets.length, 1);
  strictEqual(assets[0].label, "WBTC");
  strictEqual(assets[0].source, "supplied");
  ok(!assets.some((a) => a.label.includes("aArb")));
});

test("assets: wallet + supplied; borrowed excluded and not negative", () => {
  const assets = buildAssetAllocation(
    [holding({ valueUsd: "100.00" })],
    {
      supplied: [supplied({ valueUsd: "4000.00" })],
      borrowed: [borrowed({ valueUsd: "4033.40" })],
    },
  );
  strictEqual(assets.length, 2);
  ok(assets.every((a) => a.source === "wallet" || a.source === "supplied"));
  ok(!assets.some((a) => a.label === "USD₮0"));
  ok(assets.every((a) => !String(a.valueUsd).startsWith("-")));
  const pctSum = sumPercentages(assets);
  ok(pctSum.gte(99.99) && pctSum.lte(100.01));
});

test("assets: missing and zero valueUsd ignored", () => {
  const assets = buildAssetAllocation(
    [
      holding({ valueUsd: null }),
      holding({ assetSymbol: "ZERO", valueUsd: "0.00" }),
      holding({ assetSymbol: "ETH", valueUsd: "50.00" }),
    ],
    { supplied: [], borrowed: [] },
  );
  strictEqual(assets.length, 1);
  strictEqual(assets[0].label, "ETH");
});

test("debts: borrowed only, positive values, near 100% total", () => {
  const debts = buildDebtAllocation({
    supplied: [],
    borrowed: [borrowed(), borrowed({ valueUsd: "10.00", underlyingSymbol: "USDC" })],
  });
  strictEqual(debts.length, 2);
  ok(debts.every((d) => d.source === "borrowed"));
  ok(debts.every((d) => new Decimal(d.valueUsd).gt(0)));
  const pctSum = sumPercentages(debts);
  ok(pctSum.gte(99.99) && pctSum.lte(100.01));
});

test("debts do not appear in assets", () => {
  const { assets, debts } = buildPortfolioAllocation({
    walletHoldings: [],
    protocolPositions: {
      supplied: [supplied({ valueUsd: "100.00" })],
      borrowed: [borrowed()],
    },
    protocolSummaries: [],
  });
  ok(debts.some((d) => d.label === "USD₮0"));
  ok(!assets.some((a) => a.label === "USD₮0"));
});

test("protocols: wallet + aave netValueUsd", () => {
  const protocols = buildProtocolAllocation([
    {
      protocol: "wallet",
      protocolName: "Wallet",
      category: "wallet",
      walletValueUsd: "366.77",
      suppliedValueUsd: "0.00",
      borrowedValueUsd: "0.00",
      grossValueUsd: "366.77",
      netValueUsd: "366.77",
    },
    {
      protocol: "aave_v3",
      protocolName: "Aave V3",
      category: "lending",
      walletValueUsd: "0.00",
      suppliedValueUsd: "8394.27",
      borrowedValueUsd: "4033.40",
      grossValueUsd: "8394.27",
      netValueUsd: "4360.87",
    },
  ]);
  strictEqual(protocols.length, 2);
  const aave = protocols.find((p) => p.protocol === "aave_v3");
  strictEqual(aave.valueUsd, "4360.87");
  strictEqual(aave.netValueUsd, "4360.87");
  const pctSum = sumPercentages(protocols);
  ok(pctSum.gte(99.99) && pctSum.lte(100.01));
});

test("protocols omit zero or negative netValueUsd", () => {
  const protocols = buildProtocolAllocation([
    {
      protocol: "wallet",
      protocolName: "Wallet",
      category: "wallet",
      netValueUsd: "0.00",
      walletValueUsd: "0.00",
      suppliedValueUsd: "0.00",
      borrowedValueUsd: "0.00",
      grossValueUsd: "0.00",
    },
  ]);
  strictEqual(protocols.length, 0);
});

test("networks: wallet + supplied - borrowed", () => {
  const networks = buildNetworkAllocation(
    [holding({ networkId: 2, network: "arbitrum", valueUsd: "1.32" })],
    {
      supplied: [supplied({ valueUsd: "8364.72" })],
      borrowed: [borrowed({ valueUsd: "4033.40" })],
    },
  );
  strictEqual(networks.length, 1);
  strictEqual(networks[0].network, "arbitrum");
  strictEqual(networks[0].netValueUsd, "4332.64");
  strictEqual(networks[0].valueUsd, "4332.64");
  strictEqual(networks[0].borrowedValueUsd, "4033.40");
});

test("networks omit non-positive net value", () => {
  const networks = buildNetworkAllocation([], {
    supplied: [],
    borrowed: [borrowed({ valueUsd: "5000.00" })],
  });
  strictEqual(networks.length, 0);
});

test("network percentages sum to ~100", () => {
  const networks = buildNetworkAllocation(
    [holding({ networkId: 1, valueUsd: "365.45" })],
    {
      supplied: [supplied({ networkId: 1, network: "ethereum", valueUsd: "9.29" })],
      borrowed: [],
    },
  );
  const pctSum = sumPercentages(networks);
  ok(pctSum.gte(99.99) && pctSum.lte(100.01));
});

test("Other grouping: maxItems and minPercentage", () => {
  const items = Array.from({ length: 10 }, (_, i) => ({
    key: `A${i}`,
    label: `A${i}`,
    valueUsd: i === 0 ? "90.00" : "1.00",
  }));
  const grouped = groupSmallAllocationItems(items, "99.00", {
    maxItems: 3,
    minPercentage: "1.00",
  });
  const other = grouped.find((g) => g.key === "other");
  ok(other);
  strictEqual(other.childrenCount, 7);
  strictEqual(other.valueUsd, "7.00");
  strictEqual(grouped.length, 4);
  const pctSum = sumPercentages(grouped);
  ok(pctSum.gte(99.99) && pctSum.lte(100.01));
});

test("calculatePercentages uses decimal-safe formatting", () => {
  const out = calculatePercentages(
    [{ valueUsd: "33.33" }, { valueUsd: "66.67" }],
    "100.00",
  );
  strictEqual(out[0].percentage, "33.33");
  strictEqual(out[1].percentage, "66.67");
});

test("buildPortfolioAllocation returns all sections including wallets", () => {
  const allocation = buildPortfolioAllocation({
    walletHoldings: [holding()],
    protocolPositions: {
      supplied: [supplied()],
      borrowed: [borrowed()],
    },
    protocolSummaries: [
      {
        protocol: "wallet",
        protocolName: "Wallet",
        category: "wallet",
        netValueUsd: "100.00",
        walletValueUsd: "100.00",
        suppliedValueUsd: "0.00",
        borrowedValueUsd: "0.00",
        grossValueUsd: "100.00",
      },
    ],
    wallets: [walletSelector("1", { walletValueUsd: "100.00", netValueUsd: "100.00" })],
  });
  ok(Array.isArray(allocation.assets));
  ok(Array.isArray(allocation.debts));
  ok(Array.isArray(allocation.protocols));
  ok(Array.isArray(allocation.networks));
  ok(Array.isArray(allocation.wallets));
  strictEqual(allocation.wallets.length, 1);
});

test("global allocation unchanged when wallets passed", () => {
  const base = buildPortfolioAllocation({
    walletHoldings: [holding({ assetSymbol: "ETH", symbol: "ETH", valueUsd: "50.00" })],
    protocolPositions: { supplied: [], borrowed: [] },
    protocolSummaries: [],
  });
  const withWallets = buildPortfolioAllocation({
    walletHoldings: [holding({ assetSymbol: "ETH", symbol: "ETH", valueUsd: "50.00" })],
    protocolPositions: { supplied: [], borrowed: [] },
    protocolSummaries: [],
    wallets: [walletSelector("1", { walletValueUsd: "50.00", netValueUsd: "50.00" })],
  });
  deepStrictEqual(
    { assets: base.assets, debts: base.debts, protocols: base.protocols, networks: base.networks },
    {
      assets: withWallets.assets,
      debts: withWallets.debts,
      protocols: withWallets.protocols,
      networks: withWallets.networks,
    },
  );
});

test("wallet-scoped assets: holdings only for selected wallet", () => {
  const assets = buildWalletAssetAllocation(
    "1",
    [
      holding({
        assetSymbol: "wstETH",
        wallets: [nestedWallet("1", { valueUsd: "363.05" })],
      }),
      holding({
        assetSymbol: "LINK",
        wallets: [nestedWallet("2", { valueUsd: "10.16" })],
      }),
    ],
    { supplied: [], borrowed: [] },
  );
  strictEqual(assets.length, 1);
  strictEqual(assets[0].label, "wstETH");
  ok(!assets.some((a) => a.label === "LINK"));
});

test("wallet-scoped assets: supplied uses underlyingSymbol and excludes debt", () => {
  const assets = buildWalletAssetAllocation(
    "1",
    [],
    {
      supplied: [supplied({ underlyingSymbol: "WBTC", tokenSymbol: "aArbWBTC" })],
      borrowed: [borrowed()],
    },
  );
  strictEqual(assets.length, 1);
  strictEqual(assets[0].label, "WBTC");
  strictEqual(assets[0].source, "supplied");
  ok(!assets.some((a) => a.label === "USD₮0"));
});

test("wallet-scoped debts: borrowed only for selected wallet", () => {
  const debts = buildWalletDebtAllocation("1", {
    supplied: [],
    borrowed: [
      borrowed({
        wallets: [
          nestedWallet("1", { valueUsd: "4033.40" }),
          nestedWallet("2", { valueUsd: "1.00" }),
        ],
      }),
    ],
  });
  strictEqual(debts.length, 1);
  strictEqual(debts[0].label, "USD₮0");
  strictEqual(debts[0].valueUsd, "4033.40");
});

test("wallet-scoped debts empty when wallet has no borrow", () => {
  const debts = buildWalletDebtAllocation("2", {
    supplied: [],
    borrowed: [borrowed({ wallets: [nestedWallet("1", { valueUsd: "4033.40" })] })],
  });
  strictEqual(debts.length, 0);
});

test("multiple wallets do not leak values across allocations", () => {
  const allocations = buildWalletAllocations(
    [
      walletSelector("1", { walletValueUsd: "2.58", netValueUsd: "4353.29" }),
      walletSelector("2", { walletValueUsd: "364.19", netValueUsd: "374.35" }),
    ],
    [
      holding({
        assetSymbol: "wstETH",
        wallets: [nestedWallet("2", { valueUsd: "363.05" })],
      }),
      holding({
        assetSymbol: "UNI",
        wallets: [nestedWallet("1", { valueUsd: "1.26" })],
      }),
    ],
    {
      supplied: [
        supplied({
          underlyingSymbol: "WBTC",
          wallets: [nestedWallet("1", { valueUsd: "4074.66" })],
        }),
      ],
      borrowed: [
        borrowed({
          wallets: [nestedWallet("1", { valueUsd: "4033.40" })],
        }),
      ],
    },
  );

  const wallet1 = allocations.find((w) => w.walletId === "1");
  const wallet2 = allocations.find((w) => w.walletId === "2");

  ok(wallet1.assets.some((a) => a.label === "WBTC"));
  ok(!wallet1.assets.some((a) => a.label === "wstETH"));
  ok(wallet1.debts.some((d) => d.label === "USD₮0"));

  ok(wallet2.assets.some((a) => a.label === "wstETH"));
  ok(!wallet2.assets.some((a) => a.label === "WBTC"));
  strictEqual(wallet2.debts.length, 0);
});

test("wallet-scoped protocols use net values per wallet", () => {
  const protocols = buildWalletProtocolAllocation(
    walletSelector("1", {
      walletValueUsd: "500.00",
      suppliedValueUsd: "1000.00",
      borrowedValueUsd: "200.00",
      grossValueUsd: "1500.00",
      netValueUsd: "1300.00",
    }),
    {
      supplied: [supplied({ wallets: [nestedWallet("1", { valueUsd: "1000.00" })] })],
      borrowed: [borrowed({ wallets: [nestedWallet("1", { valueUsd: "200.00" })] })],
    },
  );
  const aave = protocols.find((p) => p.protocol === "aave_v3");
  const walletProto = protocols.find((p) => p.protocol === "wallet");
  strictEqual(walletProto.valueUsd, "500.00");
  strictEqual(aave.netValueUsd, "800.00");
  strictEqual(aave.valueUsd, "800.00");
});

test("wallet-scoped networks use wallet + supplied - borrowed", () => {
  const networks = buildWalletNetworkAllocation(
    "1",
    [holding({ networkId: 2, network: "arbitrum", wallets: [nestedWallet("1", { valueUsd: "1.32" })] })],
    {
      supplied: [
        supplied({
          networkId: 2,
          wallets: [nestedWallet("1", { valueUsd: "8364.72" })],
        }),
      ],
      borrowed: [
        borrowed({
          networkId: 2,
          wallets: [nestedWallet("1", { valueUsd: "4033.40" })],
        }),
      ],
    },
  );
  strictEqual(networks.length, 1);
  strictEqual(networks[0].network, "arbitrum");
  strictEqual(networks[0].netValueUsd, "4332.64");
  strictEqual(networks[0].valueUsd, "4332.64");
});

test("wallet-scoped percentages sum near 100", () => {
  const assets = buildWalletAssetAllocation(
    "1",
    [holding({ wallets: [nestedWallet("1", { valueUsd: "60.00" })] })],
    {
      supplied: [
        supplied({ underlyingSymbol: "WBTC", wallets: [nestedWallet("1", { valueUsd: "40.00" })] }),
      ],
      borrowed: [],
    },
  );
  const pctSum = sumPercentages(assets);
  ok(pctSum.gte(99.99) && pctSum.lte(100.01));
});

test("wallet-scoped ignores null nested valueUsd", () => {
  const assets = buildWalletAssetAllocation(
    "1",
    [holding({ wallets: [nestedWallet("1", { valueUsd: null })] })],
    { supplied: [], borrowed: [] },
  );
  strictEqual(assets.length, 0);
});

test("findNestedWalletEntry matches walletId", () => {
  const row = holding({ wallets: [nestedWallet("4", { valueUsd: "1.00" })] });
  ok(findNestedWalletEntry(row, "4"));
  strictEqual(findNestedWalletEntry(row, "5"), null);
});

test("valueUsd and percentage are 2-decimal strings", () => {
  const assets = buildAssetAllocation(
    [holding({ valueUsd: "10.126" })],
    { supplied: [], borrowed: [] },
  );
  strictEqual(assets[0].valueUsd, "10.13");
  ok(/^\d+\.\d{2}$/.test(assets[0].percentage));
});

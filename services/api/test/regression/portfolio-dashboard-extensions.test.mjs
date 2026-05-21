import { deepStrictEqual, strictEqual, ok } from "node:assert";
import { test } from "node:test";

import {
  buildPortfolioAggregationFromRows,
  buildProtocolAggregationFromRows,
  buildProtocolSummaries,
  buildWalletHoldings,
  buildWalletsSelector,
  buildDefiRisk,
  DEFAULT_PRICE_STALE_AFTER_MS,
  withWalletAliases,
} from "../../src/services/portfolio/portfolioAggregation.service.js";

const NOW = "2026-05-19T13:30:00.000Z";

function baseWalletRow(overrides = {}) {
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

function baseProtocolRow(overrides = {}) {
  return {
    wallet_id: "1",
    wallet_address: "0x1111111111111111111111111111111111111111",
    wallet_label: "Main",
    protocol_asset_token_id: "100",
    balance_raw: "1000000000000000000",
    balance_synced_at: "2026-05-19T13:21:00.000Z",
    block_number: "22500111",
    protocol: "aave",
    position_side: "supplied",
    token_role: "a_token",
    network_id: 1,
    chain_id: 1,
    network_name: "ethereum",
    native_symbol: "ETH",
    token_address: "0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    token_symbol: "aWETH",
    token_decimals: 18,
    underlying_asset_id: "11",
    underlying_address: "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
    underlying_symbol: "WETH",
    underlying_decimals: 18,
    price_asset_id: "11",
    price_asset_address: "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
    price_asset_symbol: "WETH",
    price_usd: "2000",
    price_calculated_at: "2026-05-19T13:20:00.000Z",
    price_updated_at: "2026-05-19T13:20:10.000Z",
    ...overrides,
  };
}

const aggOptions = {
  now: NOW,
  staleAfterMs: DEFAULT_PRICE_STALE_AFTER_MS,
};

test("withWalletAliases adds walletAddress and walletLabel without removing address/label", () => {
  deepStrictEqual(
    withWalletAliases({
      walletId: "1",
      address: "0xabc",
      label: "Main",
      amount: "1.0",
    }),
    {
      walletId: "1",
      address: "0xabc",
      label: "Main",
      walletAddress: "0xabc",
      walletLabel: "Main",
      amount: "1.0",
    },
  );
});

test("walletHoldings and protocolPositions expose full priceStatus including stale", () => {
  const walletAgg = buildPortfolioAggregationFromRows(
    [
      baseWalletRow({
        price_calculated_at: "2026-05-19T10:00:00.000Z",
      }),
    ],
    aggOptions,
  );
  const flatHoldings = buildWalletHoldings(walletAgg.networks);
  strictEqual(flatHoldings[0].priceStatus, "stale");

  const protocolAgg = buildProtocolAggregationFromRows(
    [
      baseProtocolRow({
        price_calculated_at: "2026-05-19T10:00:00.000Z",
      }),
    ],
    aggOptions,
  );
  strictEqual(protocolAgg.supplied[0].priceStatus, "stale");
  strictEqual(protocolAgg.supplied[0].priceUsd, "2000");
  strictEqual(protocolAgg.supplied[0].valueUsd, "2000.00");
});

test("nested wallets in holdings and protocol positions include aliases", () => {
  const walletAgg = buildPortfolioAggregationFromRows([baseWalletRow()], aggOptions);
  const protocolAgg = buildProtocolAggregationFromRows(
    [baseProtocolRow()],
    aggOptions,
  );

  const holdingWallets = buildWalletHoldings(walletAgg.networks)[0].wallets;
  ok(holdingWallets[0].walletAddress);
  ok("walletLabel" in holdingWallets[0]);
  strictEqual(holdingWallets[0].address, holdingWallets[0].walletAddress);

  const protocolWallets = protocolAgg.supplied[0].wallets;
  strictEqual(protocolWallets[0].walletAddress, protocolWallets[0].address);
  strictEqual(protocolWallets[0].walletLabel, "Main");
});

test("buildWalletsSelector returns empty array when user has no wallets", () => {
  deepStrictEqual(buildWalletsSelector([], [], { supplied: [], borrowed: [] }, []), []);
});

test("buildWalletsSelector includes zero-value wallet rows for registered wallets", () => {
  const wallets = buildWalletsSelector(
    [
      {
        id: "1",
        address: "0x1111111111111111111111111111111111111111",
        label: "Main",
      },
    ],
    [],
    { supplied: [], borrowed: [] },
    [],
  );

  strictEqual(wallets.length, 1);
  strictEqual(wallets[0].walletValueUsd, "0.00");
  strictEqual(wallets[0].suppliedValueUsd, "0.00");
  strictEqual(wallets[0].borrowedValueUsd, "0.00");
  strictEqual(wallets[0].netValueUsd, "0.00");
  strictEqual(wallets[0].healthFactorStatus, "missing");
});

test("buildWalletsSelector separates totals per wallet", () => {
  const walletAgg = buildPortfolioAggregationFromRows(
    [
      baseWalletRow(),
      baseWalletRow({
        wallet_id: "2",
        wallet_address: "0x2222222222222222222222222222222222222222",
        wallet_label: null,
        balance_raw: "50000000",
      }),
    ],
    aggOptions,
  );
  const holdings = walletAgg.networks[0].assets[0].wallets.map(withWalletAliases);

  const wallets = buildWalletsSelector(
    [
      {
        id: "1",
        address: "0x1111111111111111111111111111111111111111",
        label: "Main",
      },
      {
        id: "2",
        address: "0x2222222222222222222222222222222222222222",
        label: null,
      },
    ],
    [
      {
        wallets: holdings,
      },
    ],
    { supplied: [], borrowed: [] },
    [],
  );

  strictEqual(wallets.length, 2);
  strictEqual(wallets[0].walletValueUsd, "100.01");
  strictEqual(wallets[1].walletValueUsd, "50.01");
});

test("buildWalletsSelector rolls up lowest finite health factor per wallet", () => {
  const wallets = buildWalletsSelector(
    [{ id: "1", address: "0x1111111111111111111111111111111111111111", label: "Main" }],
    [],
    { supplied: [], borrowed: [] },
    [
      {
        walletId: "1",
        protocol: "aave_v3",
        healthFactor: "2.50",
        threshold: "1.20",
      },
      {
        walletId: "1",
        protocol: "aave_v3",
        networkId: 2,
        healthFactor: "1.15",
        threshold: "1.20",
      },
    ],
  );

  strictEqual(wallets[0].healthFactor, "1.15");
  strictEqual(wallets[0].healthFactorStatus, "at_risk");
});

test("buildWalletsSelector uses no_debt when only Infinity HF exists for wallet", () => {
  const wallets = buildWalletsSelector(
    [{ id: "1", address: "0x1111111111111111111111111111111111111111", label: null }],
    [],
    { supplied: [], borrowed: [] },
    [
      {
        walletId: "1",
        protocol: "aave_v3",
        healthFactor: "Infinity",
        threshold: "1.20",
      },
    ],
  );

  strictEqual(wallets[0].healthFactor, "Infinity");
  strictEqual(wallets[0].healthFactorStatus, "no_debt");
});

test("buildProtocolSummaries always includes wallet pseudo-protocol", () => {
  const summaries = buildProtocolSummaries("366.60", { supplied: [], borrowed: [] }, []);
  strictEqual(summaries.length, 1);
  strictEqual(summaries[0].protocol, "wallet");
  strictEqual(summaries[0].healthFactorStatus, "none");
  strictEqual(summaries[0].totalValueUsd, "366.60");
  deepStrictEqual(summaries[0].networks, []);
});

test("buildProtocolSummaries aggregates Aave supplied and borrowed with positive borrowed display", () => {
  const protocolAgg = buildProtocolAggregationFromRows(
    [
      baseProtocolRow({ balance_raw: "2000000000000000000" }),
      baseProtocolRow({
        position_side: "borrowed",
        token_role: "variable_debt_token",
        protocol_asset_token_id: "101",
        token_address: "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
        token_symbol: "variableDebtUSDC",
        underlying_asset_id: "10",
        underlying_address: "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
        underlying_symbol: "USDC",
        underlying_decimals: 6,
        balance_raw: "1000000000",
        price_usd: "1",
      }),
    ],
    aggOptions,
  );

  const summaries = buildProtocolSummaries(
    "0.00",
    protocolAgg,
    [
      {
        protocol: "aave_v3",
        networkId: 1,
        healthFactor: "1.15",
        threshold: "1.20",
      },
    ],
  );

  const aave = summaries.find((s) => s.protocol === "aave_v3");
  ok(aave);
  strictEqual(aave.category, "lending");
  strictEqual(aave.suppliedValueUsd, "4000.00");
  strictEqual(aave.borrowedValueUsd, "1000.00");
  strictEqual(aave.netValueUsd, "3000.00");
  strictEqual(aave.healthFactor, "1.15");
  strictEqual(aave.healthFactorStatus, "at_risk");
  strictEqual(aave.networks.length, 1);
  strictEqual(aave.networks[0].netValueUsd, "3000.00");
  strictEqual(aave.networks[0].healthFactor, "1.15");
});

test("buildDefiRisk positionsHealth includes walletLabel", () => {
  const defiRisk = buildDefiRisk({
    hfRows: [
      {
        address: "0x1111111111111111111111111111111111111111",
        protocol: "aave",
        network_id: 1,
        healthfactor: 1.61,
        collected_at: "2026-05-19T13:00:00.000Z",
      },
    ],
    walletsMap: new Map([
      [
        "0x1111111111111111111111111111111111111111",
        {
          id: "1",
          address: "0x1111111111111111111111111111111111111111",
          label: "Main wallet",
        },
      ],
    ]),
    networkMap: new Map([
      [
        "1",
        {
          networkId: 1,
          name: "ethereum",
        },
      ],
    ]),
    threshold: 1.2,
  });

  strictEqual(defiRisk.positionsHealth[0].walletLabel, "Main wallet");
  strictEqual(defiRisk.positionsHealth[0].walletId, "1");
});

test("buildProtocolSummaries uses no_debt HF when stored as Infinity", () => {
  const summaries = buildProtocolSummaries(
    "0.00",
    buildProtocolAggregationFromRows([baseProtocolRow()], aggOptions),
    [
      {
        protocol: "aave_v3",
        networkId: 1,
        healthFactor: "Infinity",
        threshold: "1.20",
      },
    ],
  );

  const aave = summaries.find((s) => s.protocol === "aave_v3");
  strictEqual(aave.healthFactor, "Infinity");
  strictEqual(aave.healthFactorStatus, "no_debt");
});
